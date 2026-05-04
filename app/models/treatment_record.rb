class TreatmentRecord < ApplicationRecord
  belongs_to :patient
  belongs_to :user
  belongs_to :appointment

  has_one :invoice, dependent: :destroy

  validates :service_type, :performed_on, presence: true
  validates :cost, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
