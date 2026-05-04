class Invoice < ApplicationRecord
  belongs_to :patient
  belongs_to :treatment_record
  has_many :payments, dependent: :destroy

  STATUSES = ["draft", "for_approval", "approved", "partially_paid", "paid", "cancelled", "refunded"].freeze

  validates :status, inclusion: { in: STATUSES }
  validates :total_amount, :balance_amount, numericality: { greater_than_or_equal_to: 0 }
end
