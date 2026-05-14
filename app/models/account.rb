class Account < ApplicationRecord
  PLANS = Clinic::PLANS
  SUBSCRIPTION_STATUSES = Clinic::SUBSCRIPTION_STATUSES

  has_many :clinics, dependent: :restrict_with_exception
  has_many :account_memberships, dependent: :destroy
  has_many :members, through: :account_memberships, source: :user

  validates :name, :slug, :subscription_plan, :subscription_status, presence: true
  validates :slug, uniqueness: true, format: {
    with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/,
    message: "can only contain letters, numbers, spaces, or dashes"
  }
  validates :subscription_plan, inclusion: { in: PLANS }
  validates :subscription_status, inclusion: { in: SUBSCRIPTION_STATUSES }

  before_validation :assign_slug
  before_validation :assign_trial_ends_on
  before_validation :assign_subscription_window

  scope :active_for_access, -> { where(subscription_status: %w[trialing active past_due]) }

  def suspended?
    subscription_status == "suspended" || suspended_at.present?
  end

  def suspend!
    update!(subscription_status: "suspended", suspended_at: Time.current)
  end

  def reactivate!
    update!(subscription_status: "active", suspended_at: nil)
  end

  private

  def assign_slug
    self.slug = slug.to_s.squish.tr(" ", "-").downcase if slug.present?
    self.slug = name.to_s.parameterize if slug.blank? && name.present?
  end

  def assign_trial_ends_on
    self.trial_ends_on ||= 14.days.from_now.to_date if subscription_status == "trialing"
  end

  def assign_subscription_window
    self.subscription_starts_on ||= Date.current
    self.subscription_ends_on ||= trial_ends_on
  end
end
