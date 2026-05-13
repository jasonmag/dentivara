class Payment < ApplicationRecord
  include TenantScoped
  include Auditable

  belongs_to :invoice
  belongs_to :recorded_by, class_name: "User", foreign_key: :recorded_by_user_id, optional: true
  has_one_attached :proof

  PAYMENT_METHODS = [
    "cash",
    "bank_transfer",
    "gcash",
    "maya",
    "credit_card",
    "insurance",
    "other"
  ].freeze

  validates :amount, numericality: { greater_than: 0 }
  validates :paid_on, presence: true
  validates :method, inclusion: { in: PAYMENT_METHODS }, allow_blank: true
  validates :amount, uniqueness: { scope: [ :invoice_id, :paid_on, :method, :reference_code ], message: "looks like a duplicate payment entry" }
  validate :proof_content_type
  validate :proof_size

  after_commit :refresh_invoice_balance, on: %i[create update destroy]

  private

  def refresh_invoice_balance
    return unless Invoice.exists?(invoice_id)

    invoice.reload
    paid_total = invoice.payments.sum(:amount).to_d
    total_amount = invoice.total_amount.to_d
    new_balance = [total_amount - paid_total, 0.to_d].max
    next_status = if paid_total > total_amount
      "overpaid"
    elsif new_balance.zero?
      "paid"
    elsif paid_total.positive?
      "partially_paid"
    else
      "approved"
    end
    invoice.update_columns(balance_amount: new_balance, status: next_status, updated_at: Time.current)
  end

  def proof_content_type
    return unless proof.attached?

    unless proof.content_type.in?(%w[image/jpeg image/png application/pdf])
      errors.add(:proof, "must be a JPG, PNG, or PDF file")
    end
  end

  def proof_size
    return unless proof.attached?
    return if proof.byte_size <= 10.megabytes

    errors.add(:proof, "must be 10MB or less")
  end
end
