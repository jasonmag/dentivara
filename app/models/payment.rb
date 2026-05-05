class Payment < ApplicationRecord
  include Auditable

  belongs_to :invoice

  validates :amount, numericality: { greater_than: 0 }
  validates :paid_on, presence: true

  after_commit :refresh_invoice_balance, on: %i[create update destroy]

  private

  def refresh_invoice_balance
    return unless Invoice.exists?(invoice_id)

    invoice.reload
    paid_total = invoice.payments.sum(:amount)
    new_balance = [invoice.total_amount.to_d - paid_total, 0.to_d].max
    next_status = if new_balance.zero?
      "paid"
    elsif paid_total.positive?
      "partially_paid"
    else
      invoice.status
    end
    invoice.update_columns(balance_amount: new_balance, status: next_status, updated_at: Time.current)
  end
end
