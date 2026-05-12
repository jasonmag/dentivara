class Invoice < ApplicationRecord
  include Auditable

  belongs_to :patient
  belongs_to :treatment_record
  has_many :payments, dependent: :destroy
  delegate :appointment, to: :treatment_record, allow_nil: true

  STATUSES = ["draft", "for_approval", "approved", "partially_paid", "paid", "overpaid", "cancelled", "refunded"].freeze

  validates :status, inclusion: { in: STATUSES }
  validates :total_amount, :balance_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :invoice_number, uniqueness: true, allow_blank: true

  after_create :assign_invoice_number
  after_commit :queue_billing_notification, on: %i[create update]

  def total_paid
    payments.sum(:amount).to_d
  end

  def credit_amount
    [total_paid - total_amount.to_d, 0.to_d].max
  end

  def payment_progress_percentage
    return 0 if total_amount.to_d <= 0

    [((total_paid / total_amount.to_d) * 100).to_f, 100.0].min
  end

  private

  def queue_billing_notification
    return unless balance_amount.to_d.positive?
    return if patient.email.blank?
    return unless saved_change_to_balance_amount? || previously_new_record?
    return if Notification.where(source_record: self, category: "billing").where("created_at >= ?", 12.hours.ago).exists?

    Notification.create!(
      patient: patient,
      channel: "email",
      category: "billing",
      scheduled_for: Time.current,
      status: "pending",
      message: "Invoice ##{id} has an outstanding balance of #{balance_amount}.",
      source_record: self
    )
  end

  def assign_invoice_number
    return if invoice_number.present?

    year = issued_on&.year || Time.zone.today.year
    update_column(:invoice_number, format("INV-%<year>d-%<id>05d", year: year, id: id))
  end
end
