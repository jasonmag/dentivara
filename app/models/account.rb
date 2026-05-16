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
    return false unless subscription_status.in?(%w[active trialing])
    return false if subscription_ends_on.present? && subscription_ends_on < Date.current

    included_clinics = SubscriptionPlan.find_by(code: subscription_plan)&.clinics_included
    return true if included_clinics.blank?

    clinics.count < included_clinics
  end

  private

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
