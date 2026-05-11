require "test_helper"

class ApiV1PaymentsTest < ActionDispatch::IntegrationTest
  setup do
    @previous_token = ENV["API_V1_TOKEN"]
    ENV["API_V1_TOKEN"] = nil
    @headers = api_headers_for(users(:three))
    @invoice = invoices(:one)
  end

  teardown do
    ENV["API_V1_TOKEN"] = @previous_token
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
    assert_equal first_body.dig("data", "id"), replay_body.dig("data", "id")
    assert_equal users(:three).id, first_body.dig("data", "recorded_by_user_id")
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
    assert_equal "idempotency_conflict", JSON.parse(response.body).dig("error", "code")
  end

  test "lists payments with filter and pagination metadata" do
    get api_v1_payments_url, headers: @headers, params: { invoice_id: @invoice.id, per_page: 1 }, as: :json
    assert_response :success

    body = JSON.parse(response.body)
    assert body["data"].all? { |payment| payment["invoice_id"] == @invoice.id }
    assert_equal 1, body.dig("meta", "pagination", "per_page")
  end
end
