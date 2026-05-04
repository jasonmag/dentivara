class Patient < ApplicationRecord
  has_many :appointments, dependent: :destroy
  has_many :treatment_records, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :notifications, dependent: :destroy

  validates :first_name, :last_name, :phone, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end
end
