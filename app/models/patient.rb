class Patient < ApplicationRecord
  include Auditable

  belongs_to :user, optional: true
  has_many :appointments, dependent: :destroy
  has_many :treatment_records, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :patient_consents, dependent: :destroy

  encrypts :medical_history, :emergency_contact_name, :emergency_contact_phone

  validates :first_name, :last_name, :phone, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end
end
