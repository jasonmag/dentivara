class ClinicService < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :base_price, numericality: { greater_than_or_equal_to: 0 }
  validates :duration_minutes, numericality: { greater_than: 0 }
end
