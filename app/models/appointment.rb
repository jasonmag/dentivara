class Appointment < ApplicationRecord
  include Auditable

  belongs_to :patient
  belongs_to :user
  has_many :treatment_records, dependent: :destroy

  BOOKING_SOURCES = %w[online social_media phone sms walk_in admin].freeze
  BOOKING_TYPES = %w[scheduled walk_in emergency call_waiting follow_up].freeze
  STATUSES = %w[pending confirmed completed cancelled no_show].freeze

  validates :source, inclusion: { in: BOOKING_SOURCES }
  validates :booking_type, inclusion: { in: BOOKING_TYPES }
  validates :status, inclusion: { in: STATUSES }
  validates :starts_at, :ends_at, presence: true
  validate :ends_after_start
  validate :provider_availability
  after_commit :queue_appointment_reminder, on: :create

  private

  def ends_after_start
    return if starts_at.blank? || ends_at.blank?
    return if ends_at > starts_at

    errors.add(:ends_at, "must be after start time")
  end

  def provider_availability
    return if starts_at.blank? || ends_at.blank? || user_id.blank?

    overlapping = self.class.where(user_id: user_id)
                            .where.not(id: id)
                            .where("starts_at < ? AND ends_at > ?", ends_at, starts_at)
                            .exists?
    return unless overlapping

    errors.add(:base, "Dentist is not available in the selected time slot")
  end

  def queue_appointment_reminder
    return if patient.email.blank?

    Notification.create!(
      patient: patient,
      channel: "email",
      category: "appointment",
      scheduled_for: [starts_at - 24.hours, Time.current].max,
      status: "pending",
      message: "Reminder: You have an appointment on #{starts_at.strftime('%B %d, %Y at %I:%M %p')}.",
      source_record: self
    )
  end
end
