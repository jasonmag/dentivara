class ClinicSchedule < ApplicationRecord
  DAYS = Date::DAYNAMES.each_with_index.to_h.freeze

  validates :day_of_week, presence: true, inclusion: { in: 0..6 }, uniqueness: true
  validates :max_concurrent_appointments, numericality: { greater_than: 0 }
  validates :opens_at, :closes_at, presence: true, unless: :closed?
  validate :closes_after_opening

  scope :open, -> { where(closed: false) }

  def self.for_date(date)
    find_by(day_of_week: date.wday)
  end

  def day_name
    Date::DAYNAMES[day_of_week]
  end

  private

  def closes_after_opening
    return if closed? || opens_at.blank? || closes_at.blank?
    return if closes_at > opens_at

    errors.add(:closes_at, "must be after opening time")
  end
end
