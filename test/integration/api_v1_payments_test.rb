require "test_helper"

class ApiV1PaymentsTest < ActionDispatch::IntegrationTest
  setup do
    @headers = { "Authorization" => "Bearer dev-token" }
    @invoice = invoices(:one)
  end

  test "creates payment with idempotency key and replays same response" do
    payload = {
      payment: {
        invoice_id: @invoice.id,
        amount: 321.25,
        paid_on: "2026-05-09",
        method: "gcash",
        reference_code: "IDEMP-001"
      }
    }

    assert_difference("Payment.count", 1) do
      post api_v1_payments_url, params: payload, headers: @headers.merge("Idempotency-Key" => "payment-create-1"), as: :json
    end
    assert_response :created
    first_body = JSON.parse(response.body)

    assert_no_difference("Payment.count") do
      post api_v1_payments_url, params: payload, headers: @headers.merge("Idempotency-Key" => "payment-create-1"), as: :json
    end
    assert_response :created
    replay_body = JSON.parse(response.body)
    assert_equal first_body["id"], replay_body["id"]
  end

  test "rejects idempotency key reuse for different payload" do
    first_payload = {
      payment: {
        invoice_id: @invoice.id,
        amount: 400,
        paid_on: "2026-05-09",
        method: "cash",
        reference_code: "IDEMP-002"
      }
    }

    second_payload = {
      payment: {
        invoice_id: @invoice.id,
        amount: 500,
        paid_on: "2026-05-09",
        method: "cash",
        reference_code: "IDEMP-003"
      }
    }

    post api_v1_payments_url, params: first_payload, headers: @headers.merge("Idempotency-Key" => "payment-create-2"), as: :json
    assert_response :created

    post api_v1_payments_url, params: second_payload, headers: @headers.merge("Idempotency-Key" => "payment-create-2"), as: :json
    assert_response :conflict
  end
end
