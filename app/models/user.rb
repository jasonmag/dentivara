class User < ApplicationRecord
  include Auditable

  has_many :appointments, dependent: :destroy
  has_many :treatment_records, dependent: :destroy
  has_many :dental_chart_entries, dependent: :restrict_with_exception
  has_many :drafted_prescriptions, class_name: "Prescription", foreign_key: :drafted_by_user_id, dependent: :restrict_with_exception
  has_many :signed_prescriptions, class_name: "Prescription", foreign_key: :signed_by_user_id, dependent: :nullify
  has_one :patient, dependent: :nullify
  has_secure_password validations: false

  enum :role, {
    clinic_owner: 0,
    dentist: 1,
    receptionist: 2,
    billing_staff: 3,
    patient: 4,
    system_admin: 5
  }, default: :receptionist

  validates :name, :email, :role, presence: true
  validates :email, uniqueness: true
  validates :password, length: { minimum: 8 }, allow_nil: true
end
