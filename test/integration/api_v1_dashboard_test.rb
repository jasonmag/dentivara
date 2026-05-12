require "test_helper"

class ApiV1DashboardTest < ActionDispatch::IntegrationTest
  setup do
    @previous_token = ENV["API_V1_TOKEN"]
    ENV["API_V1_TOKEN"] = nil
    @headers = api_headers_for(users(:one))
  end

  teardown do
    ENV["API_V1_TOKEN"] = @previous_token
  end

  test "rejects unauthorized access" do
    get api_v1_dashboard_url, as: :json

    assert_response :unauthorized
    assert_equal "unauthorized", JSON.parse(response.body).dig("error", "code")
  end

  test "returns compact dashboard data in one response" do
    get api_v1_dashboard_url,
      headers: @headers,
      params: {
        patients_per_page: 1,
        appointments_per_page: 1,
        invoices_per_page: 1,
        starts_from: "2026-05-01T00:00:00Z",
        issued_from: "2026-05-01"
      },
      as: :json

    assert_response :success

    body = JSON.parse(response.body)
    data = body.fetch("data")

    assert_equal 1, data.dig("patients", "data").length
    assert_equal 1, data.dig("appointments", "data").length
    assert_equal 1, data.dig("invoices", "data").length
    assert_equal Patient.count, data.dig("patients", "meta", "pagination", "total_count")

    invoice = data.dig("invoices", "data", 0)
    assert invoice.key?("balance_amount")
    assert invoice.key?("patient")
    assert_not invoice.key?("payments")
  end

  test "rejects users without dashboard api permissions" do
    get api_v1_dashboard_url, headers: api_headers_for(users(:four)), as: :json

    assert_response :forbidden
    assert_equal "forbidden", JSON.parse(response.body).dig("error", "code")
  end
end
