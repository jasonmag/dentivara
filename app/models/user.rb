class User < ApplicationRecord
  has_many :appointments, dependent: :destroy
  has_many :treatment_records, dependent: :destroy

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
end
