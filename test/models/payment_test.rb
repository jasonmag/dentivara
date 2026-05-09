require "test_helper"

class PaymentTest < ActiveSupport::TestCase
  test "refreshes invoice status and balance as partially paid" do
    invoice = invoices(:one)
    invoice.update!(total_amount: 1500, balance_amount: 1500, status: "approved")
    invoice.payments.destroy_all

    Payment.create!(
      invoice: invoice,
      amount: 500,
      paid_on: Date.current,
      method: "cash",
      reference_code: "PARTIAL-001",
      recorded_by: users(:one)
    )

    invoice.reload
    assert_equal 1000.to_d, invoice.balance_amount.to_d
    assert_equal "partially_paid", invoice.status
  end

  test "marks invoice as overpaid when payment exceeds total" do
    invoice = invoices(:one)
    invoice.update!(total_amount: 1000, balance_amount: 1000, status: "approved")
    invoice.payments.destroy_all

    Payment.create!(
      invoice: invoice,
      amount: 1200,
      paid_on: Date.current,
      method: "gcash",
      reference_code: "OVERPAY-001",
      recorded_by: users(:one)
    )

    invoice.reload
    assert_equal 0.to_d, invoice.balance_amount.to_d
    assert_equal "overpaid", invoice.status
    assert_equal 200.to_d, invoice.credit_amount.to_d
  end
end
