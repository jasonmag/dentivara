require "test_helper"

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @payment = payments(:one)
    sign_in_as(users(:one))
  end

  test "should get index" do
    get payments_url
    assert_response :success
  end

  test "should get new" do
    get new_payment_url
    assert_response :success
  end

  test "should create payment" do
    assert_difference("Payment.count") do
      post payments_url, params: { payment: { amount: 321.55, invoice_id: @payment.invoice_id, method: "cash", paid_on: @payment.paid_on, reference_code: "OR-NEW-#{SecureRandom.hex(3)}" } }
    end

    assert_redirected_to invoice_url(@payment.invoice_id)
  end

  test "should show payment" do
    get payment_url(@payment)
    assert_response :success
  end

  test "should download receipt pdf" do
    get receipt_payment_url(@payment)

    assert_response :success
    assert_equal "application/pdf", response.media_type
  end

  test "should get edit" do
    get edit_payment_url(@payment)
    assert_response :success
  end

  test "should update payment" do
    patch payment_url(@payment), params: { payment: { amount: @payment.amount, invoice_id: @payment.invoice_id, method: @payment.method, paid_on: @payment.paid_on, reference_code: @payment.reference_code } }
    assert_redirected_to invoice_url(@payment.invoice)
  end

  test "should destroy payment" do
    assert_difference("Payment.count", -1) do
      delete payment_url(@payment)
    end

    assert_redirected_to invoice_url(invoices(:one))
  end
end
