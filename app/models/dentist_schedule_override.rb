class DentistScheduleOverride < ApplicationRecord
  include TenantScoped

  belongs_to :user

  validates :date, presence: true, uniqueness: { scope: %i[clinic_id user_id] }
  validates :available_from, :available_until, presence: true, unless: :unavailable?
  validate :user_is_dentist
  validate :available_until_after_available_from

  private

  def user_is_dentist
    return if user&.dentist?

    errors.add(:user, "must be a dentist")
  end

  def available_until_after_available_from
    return if unavailable? || available_from.blank? || available_until.blank?
    return if available_until > available_from

    errors.add(:available_until, "must be after available from")
  end
end
