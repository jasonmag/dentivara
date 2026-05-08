class Appointment < ApplicationRecord
  include Auditable

  belongs_to :patient
  belongs_to :user
  belongs_to :clinic_service, optional: true
  belongs_to :preferred_user, class_name: "User", optional: true
  belongs_to :rescheduled_from_appointment, class_name: "Appointment", optional: true
  has_many :rescheduled_appointments, class_name: "Appointment", foreign_key: :rescheduled_from_appointment_id, dependent: :nullify
  has_many :treatment_records, dependent: :destroy
  has_one :invoice, through: :treatment_records

  BOOKING_SOURCES = %w[online social_media phone sms walk_in admin].freeze
  BOOKING_TYPES = %w[scheduled walk_in emergency call_waiting follow_up].freeze
  STATUSES = %w[pending confirmed checked_in in_progress completed cancelled no_show rescheduled].freeze
  TIME_PREFERENCES = %w[any morning afternoon specific_time].freeze
  OCCUPYING_STATUSES = %w[pending confirmed checked_in in_progress completed].freeze

  validates :source, inclusion: { in: BOOKING_SOURCES }
  validates :booking_type, inclusion: { in: BOOKING_TYPES }
  validates :status, inclusion: { in: STATUSES }
  validates :time_preference, inclusion: { in: TIME_PREFERENCES }, allow_blank: true
  validates :starts_at, :ends_at, presence: true
  validates :duration_minutes, numericality: { greater_than: 0 }, allow_blank: true
  validates :buffer_minutes, numericality: { greater_than_or_equal_to: 0 }
  validate :preferred_user_is_dentist
  validate :ends_after_start
  validate :starts_at_not_in_past, on: :create
  validate :matches_time_preference
  validate :scheduling_availability
  before_validation :apply_service_duration
  before_validation :assign_any_available_dentist
  before_validation :stamp_cancelled_at
  after_commit :queue_invoice_sync, on: %i[create update]
  after_commit :queue_appointment_reminder, on: :create

  scope :occupying_schedule, -> { where(status: OCCUPYING_STATUSES) }

  def billing_invoice
    return nil unless status == "completed"

    treatment_records.includes(:invoice).find { |record| record.invoice.present? }&.invoice
  end

  private

  def apply_service_duration
    self.duration_minutes ||= clinic_service&.duration_minutes
    self.ends_at ||= starts_at + duration_minutes.minutes if starts_at.present? && duration_minutes.present?
  end

  def assign_any_available_dentist
    return if user_id.present? || starts_at.blank? || ends_at.blank?

    self.user = scheduler.first_available_dentist(starts_at)
  end

  def stamp_cancelled_at
    self.cancelled_at ||= Time.current if status == "cancelled" && will_save_change_to_status?
  end

  def ends_after_start
    return if starts_at.blank? || ends_at.blank?
    return if ends_at > starts_at

    errors.add(:ends_at, "must be after start time")
  end

  def starts_at_not_in_past
    return if starts_at.blank? || starts_at >= Time.current

    errors.add(:starts_at, "cannot be in the past")
  end

  def scheduling_availability
    return if starts_at.blank? || ends_at.blank?
    return if %w[cancelled no_show rescheduled].include?(status)

    errors.add(:base, "Clinic is not open for the selected time") unless scheduler.clinic_open_for?(starts_at, ends_at, booking_type: booking_type)

    if user_id.blank?
      errors.add(:user, "must be selected or have an available dentist")
    elsif !scheduler.dentist_available?(user, starts_at, ends_at, appointment: self)
      errors.add(:base, "Dentist is not available in the selected time slot")
    end

    return if scheduler.clinic_capacity_available?(starts_at, ends_at, appointment: self)

    errors.add(:base, "Clinic chair or room capacity is full for the selected time slot")
  end

  def preferred_user_is_dentist
    return if preferred_user.blank? || preferred_user.dentist?

    errors.add(:preferred_user, "must be a dentist")
  end

  def matches_time_preference
    return if starts_at.blank? || time_preference.blank? || %w[any specific_time].include?(time_preference)
    return if time_preference == "morning" && starts_at.hour < 12
    return if time_preference == "afternoon" && starts_at.hour >= 12

    errors.add(:starts_at, "does not match the selected time preference")
  end

  def scheduler
    @scheduler ||= AppointmentScheduler.new(
      date: starts_at&.to_date || Time.zone.today,
      clinic_service: clinic_service,
      duration_minutes: duration_minutes,
      preparation_minutes: clinic_service&.preparation_minutes,
      buffer_minutes: buffer_minutes,
      preferred_user: preferred_user
    )
  end

  def queue_appointment_reminder
    return if patient.email.blank?

    Notification.create!(
      patient: patient,
      channel: "email",
      category: "appointment",
      scheduled_for: [ starts_at - 24.hours, Time.current ].max,
      status: "pending",
      message: "Reminder: You have an appointment on #{starts_at.strftime('%B %d, %Y at %I:%M %p')}.",
      source_record: self
    )
  end

  def queue_invoice_sync
    return unless status == "completed"
    return unless saved_change_to_status? || billing_relevant_changes?

    AppointmentInvoiceSyncJob.perform_later(id)
  end

  def billing_relevant_changes?
    (previous_changes.keys & %w[starts_at ends_at user_id clinic_service_id notes patient_id]).any?
  end
end
