class AccountSubscription < ApplicationRecord
  belongs_to :account

  validates :subscription_plan, :subscription_status, :subscription_starts_on, :subscription_ends_on, presence: true
  validates :subscription_plan, inclusion: { in: Account::PLANS }
  validates :subscription_status, inclusion: { in: Account::SUBSCRIPTION_STATUSES }
  validate :subscription_end_not_before_start

  scope :recent_first, -> { order(subscription_starts_on: :desc, created_at: :desc) }

  private

  def subscription_end_not_before_start
    return if subscription_starts_on.blank? || subscription_ends_on.blank?
    return if subscription_ends_on >= subscription_starts_on

    errors.add(:subscription_ends_on, "must be on or after the subscription start date")
  end
end
