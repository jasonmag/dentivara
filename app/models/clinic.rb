class Clinic < ApplicationRecord
  PLANS = %w[starter clinic pro enterprise].freeze
  SUBSCRIPTION_STATUSES = %w[trialing active past_due cancelled suspended].freeze

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
  before_validation :assign_trial_ends_on

  scope :active_for_access, -> { where(subscription_status: %w[trialing active past_due]) }

  def self.default
    first_or_create!(
      name: "Dentivara Demo Clinic",
      slug: "dentivara-demo",
      contact_email: "owner@dentivara.local",
      subscription_plan: "clinic",
      subscription_status: "active",
      trial_ends_on: 30.days.from_now.to_date
    )
  end

  def suspended?
    account&.suspended? || subscription_status == "suspended" || suspended_at.present?
  end

  def suspend!
    update!(subscription_status: "suspended", suspended_at: Time.current)
  end

  def reactivate!
    update!(subscription_status: "active", suspended_at: nil)
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

  def assign_slug
    self.slug = slug.to_s.squish.tr(" ", "-").downcase if slug.present?
    self.slug = name.to_s.parameterize if slug.blank? && name.present?
  end

  def assign_trial_ends_on
    self.trial_ends_on ||= 14.days.from_now.to_date if subscription_status == "trialing"
  end
end
