class Appointment < ApplicationRecord
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

  private

  def ends_after_start
    return if starts_at.blank? || ends_at.blank?
    return if ends_at > starts_at

    errors.add(:ends_at, "must be after start time")
  end
end
