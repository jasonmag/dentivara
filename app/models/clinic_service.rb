class ClinicService < ApplicationRecord
  has_many :appointments, dependent: :nullify

  validates :name, presence: true, uniqueness: true
  validates :base_price, numericality: { greater_than_or_equal_to: 0 }
  validates :duration_minutes, numericality: { greater_than: 0 }
  validates :preparation_minutes, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }

  def occupied_minutes(buffer_minutes = 0)
    duration_minutes + preparation_minutes + buffer_minutes.to_i
  end
end
