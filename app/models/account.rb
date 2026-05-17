require "securerandom"

class Account < ApplicationRecord
  PLANS = Clinic::PLANS
  SUBSCRIPTION_STATUSES = %w[inactive trialing active past_due cancelled suspended].freeze

  has_many :clinics, dependent: :restrict_with_exception
  has_many :account_memberships, dependent: :destroy
  has_many :members, through: :account_memberships, source: :user
  has_many :account_subscriptions, dependent: :destroy

  validates :name, :slug, :subscription_plan, :subscription_status, presence: true
  validates :client_number, presence: true, uniqueness: true
  validates :slug, uniqueness: true, format: {
    with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/,
    message: "can only contain letters, numbers, spaces, or dashes"
  }
  validates :subscription_plan, inclusion: { in: PLANS }
  validates :subscription_status, inclusion: { in: SUBSCRIPTION_STATUSES }
  validate :subscription_end_not_before_start

  before_validation :assign_slug
  before_validation :assign_client_number
  before_validation :normalize_subscription_plan
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

  def subscription_allows_clinic_addition?
    clinic_allowance.fetch(:can_add_clinic)
  end

  def active_subscription
    account_subscriptions.currently_active.recent_first.first || active_subscription_snapshot
  end

  def clinic_allowance
    subscription = active_subscription
    plan_code = subscription&.subscription_plan
    plan = SubscriptionPlan.find_by(code: plan_code)
    included_clinics = plan&.clinics_included
    clinics_count = clinics.not_archived.count
    clinics_remaining = included_clinics.nil? ? nil : [ included_clinics - clinics_count, 0 ].max

    {
      active_subscription_id: subscription.is_a?(AccountSubscription) ? subscription.id : nil,
      subscription_plan: plan_code,
      subscription_status: subscription&.subscription_status,
      subscription_starts_on: subscription&.subscription_starts_on,
      subscription_ends_on: subscription&.subscription_ends_on,
      clinics_count: clinics_count,
      clinics_included: included_clinics,
      clinics_remaining: clinics_remaining,
      can_add_clinic: subscription.present? && plan.present? && (included_clinics.nil? || clinics_count < included_clinics)
    }
  end

  private

  def active_subscription_snapshot
    return unless subscription_status.in?(%w[active trialing])
    return if subscription_starts_on.present? && subscription_starts_on > Date.current
    return if subscription_ends_on.present? && subscription_ends_on < Date.current

    self
  end

  def assign_slug
    self.slug = slug.to_s.squish.tr(" ", "-").downcase if slug.present?
    self.slug = name.to_s.parameterize if slug.blank? && name.present?
  end

  def assign_client_number
    return if client_number.present?

    self.client_number = loop do
      value = "CL-#{SecureRandom.alphanumeric(8).upcase}"
      break value unless self.class.exists?(client_number: value)
    end
  end

  def normalize_subscription_plan
    self.subscription_plan = case subscription_plan
                             when "clinic"
                               "starter"
                             when "pro"
                               "growing"
                             else
                               subscription_plan.presence || "starter"
                             end
  end

  def assign_trial_ends_on
    self.trial_ends_on ||= 14.days.from_now.to_date if subscription_status == "trialing"
  end

  def assign_subscription_window
    self.subscription_starts_on ||= Date.current
    self.subscription_ends_on ||= trial_ends_on
  end

  def subscription_end_not_before_start
    return if subscription_starts_on.blank? || subscription_ends_on.blank?
    return if subscription_ends_on >= subscription_starts_on

    errors.add(:subscription_ends_on, "must be on or after the subscription start date")
  end
end
