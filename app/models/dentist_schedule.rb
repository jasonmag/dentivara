class DentistSchedule < ApplicationRecord
  belongs_to :user

  validates :day_of_week, presence: true, inclusion: { in: 0..6 }
  validates :starts_at, :ends_at, presence: true
  validate :user_is_dentist
  validate :ends_after_start

  scope :active, -> { where(active: true) }
  scope :for_date, ->(date) { where(day_of_week: date.wday) }

  def day_name
    Date::DAYNAMES[day_of_week]
  end

  private

  def user_is_dentist
    return if user&.dentist?

    errors.add(:user, "must be a dentist")
  end

  def ends_after_start
    return if starts_at.blank? || ends_at.blank?
    return if ends_at > starts_at

    errors.add(:ends_at, "must be after start time")
  end
end
