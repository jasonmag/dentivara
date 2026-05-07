class Patient < ApplicationRecord
  include Auditable

  belongs_to :user, optional: true
  has_many :appointments, dependent: :destroy
  has_many :treatment_records, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :patient_consents, dependent: :destroy
  has_many :dental_chart_entries, dependent: :destroy
  has_many :prescriptions, dependent: :destroy

  encrypts :medical_history, :emergency_contact_name, :emergency_contact_phone,
    :known_allergies, :current_medications, :medical_conditions,
    :insurance_policy_number

  validates :first_name, :last_name, :phone, presence: true
  validates :preferred_contact_method, inclusion: { in: %w[phone sms email], allow_blank: true }

  def full_name
    "#{first_name} #{last_name}"
  end
end
