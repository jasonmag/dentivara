class Patient < ApplicationRecord
  include TenantScoped
  include Auditable

  belongs_to :user, optional: true
  has_many :patient_links, dependent: :destroy
  has_many :portal_users, through: :patient_links, source: :user
  has_many :appointments, dependent: :destroy
  has_many :treatment_records, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :patient_consents, dependent: :destroy
  has_many :dental_chart_entries, dependent: :destroy
  has_many :prescriptions, dependent: :destroy
  has_many :queue_entries, dependent: :destroy
  has_many :intraoral_scans, dependent: :destroy

  encrypts :medical_history, :emergency_contact_name, :emergency_contact_phone,
    :known_allergies, :current_medications, :medical_conditions,
    :insurance_policy_number

  validates :first_name, :last_name, :phone, presence: true
  validates :claim_code, presence: true, uniqueness: true
  validates :preferred_contact_method, inclusion: { in: %w[phone sms email], allow_blank: true }
  validates :phone, format: { with: /\A\+?[0-9][0-9\-\s()]{6,19}\z/, message: "must be a valid phone number" }
  validates :emergency_contact_phone, format: { with: /\A\+?[0-9][0-9\-\s()]{6,19}\z/, message: "must be a valid phone number" }, allow_blank: true
  validate :birth_date_cannot_be_in_future
  before_validation :assign_claim_code
  after_save :ensure_patient_link_for_user, if: :saved_change_to_user_id?

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def assign_claim_code
    self.claim_code ||= self.class.generate_claim_code
  end

  def self.generate_claim_code
    loop do
      code = "PT-#{SecureRandom.alphanumeric(10).upcase}"
      return code unless unscoped.exists?(claim_code: code)
    end
  end

  def ensure_patient_link_for_user
    return if user.blank? || !user.patient?

    patient_links.find_or_create_by!(user: user) do |link|
      link.clinic = clinic
      link.claimed_at = claimed_at || Time.current
    end
    update_column(:claimed_at, Time.current) if claimed_at.blank?
  end

  def birth_date_cannot_be_in_future
    return if birth_date.blank?
    return unless birth_date > Date.current

    errors.add(:birth_date, "cannot be in the future")
  end
end
