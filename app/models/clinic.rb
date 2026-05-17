class Clinic < ApplicationRecord
  PLANS = %w[founding_clinic starter growing enterprise].freeze
  SUBSCRIPTION_STATUSES = %w[active inactive].freeze

  belongs_to :account
  has_many :users, dependent: :restrict_with_exception
  has_many :clinic_memberships, dependent: :destroy
  has_many :members, through: :clinic_memberships, source: :user
  has_many :patients, dependent: :restrict_with_exception
  has_many :appointments, dependent: :restrict_with_exception
  has_many :clinic_services, dependent: :restrict_with_exception
  has_one :clinic_setting, dependent: :destroy

  validates :name, :slug, :subscription_plan, :subscription_status, presence: true
  validates :slug, uniqueness: true, format: {
    with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/,
    message: "can only contain letters, numbers, spaces, or dashes"
  }
  validates :subscription_plan, inclusion: { in: PLANS }
  validates :subscription_status, inclusion: { in: SUBSCRIPTION_STATUSES }

  before_validation :assign_default_account
  before_validation :assign_slug
  before_validation :normalize_subscription_plan
  before_validation :normalize_subscription_status
  before_validation :assign_account_subscription
  before_validation :assign_trial_ends_on

  scope :active_for_access, -> { where(subscription_status: "active") }
  scope :archived, -> { where.not(archived_at: nil) }
  scope :not_archived, -> { where(archived_at: nil) }

  def self.default
    first_or_create!(
      name: "Dentivara Demo Clinic",
      slug: "dentivara-demo",
      contact_email: "owner@dentivara.local",
      subscription_plan: "starter",
      subscription_status: "active",
      trial_ends_on: 30.days.from_now.to_date
    )
  end

  def suspended?
    archived? || account&.suspended? || subscription_status == "inactive" || suspended_at.present?
  end

  def suspend!
    update!(subscription_status: "inactive", suspended_at: Time.current)
  end

  def archive!
    update!(subscription_status: "inactive", suspended_at: Time.current, archived_at: Time.current)
  end

  def archived?
    archived_at.present?
  end

  def reactivate!
    update!(subscription_status: "active", suspended_at: nil, archived_at: nil)
  end

  private

  def assign_default_account
    return if account.present?
    return if name.blank?

    self.account = Account.find_or_initialize_by(slug: "#{name.parameterize}-account")
    account.name ||= "#{name} Account"
    account.billing_email ||= contact_email
    account.subscription_plan ||= subscription_plan
    account.subscription_status ||= subscription_status
    account.trial_ends_on ||= trial_ends_on
  end

  def assign_account_subscription
    return if account.blank?

    self.subscription_plan = account.subscription_plan if new_record? || subscription_plan.blank?
    self.subscription_status ||= "active"
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

  def normalize_subscription_status
    self.subscription_status = case subscription_status
                               when "trialing", "past_due"
                                 "active"
                               when "cancelled", "suspended"
                                 "inactive"
                               else
                                 subscription_status.presence || "active"
                               end
  end

  def assign_slug
    self.slug = slug.to_s.squish.tr(" ", "-").downcase if slug.present?
    self.slug = name.to_s.parameterize if slug.blank? && name.present?
  end

  def assign_trial_ends_on
    self.trial_ends_on ||= account.trial_ends_on if account&.trial_ends_on.present?
  end
end
