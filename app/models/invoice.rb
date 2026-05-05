class Invoice < ApplicationRecord
  include Auditable

  belongs_to :patient
  belongs_to :treatment_record
  has_many :payments, dependent: :destroy

  STATUSES = ["draft", "for_approval", "approved", "partially_paid", "paid", "cancelled", "refunded"].freeze

  validates :status, inclusion: { in: STATUSES }
  validates :total_amount, :balance_amount, numericality: { greater_than_or_equal_to: 0 }

  after_commit :queue_billing_notification, on: %i[create update]

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
end
