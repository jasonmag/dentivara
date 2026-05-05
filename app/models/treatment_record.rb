class TreatmentRecord < ApplicationRecord
  include Auditable

  belongs_to :patient
  belongs_to :user
  belongs_to :appointment

  has_one :invoice, dependent: :destroy
  has_many_attached :clinical_files

  validates :service_type, :performed_on, presence: true
  validates :cost, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
