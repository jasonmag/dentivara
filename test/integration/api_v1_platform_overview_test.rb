require "test_helper"

class ApiV1PlatformOverviewTest < ActionDispatch::IntegrationTest
  setup do
    @system_admin = User.create!(
      clinic: clinics(:one),
      name: "System Admin",
      email: "platform-admin@example.com",
      role: :system_admin,
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "system admin can view account clinic user subscription mapping" do
    get api_v1_platform_overview_url, headers: api_headers_for(@system_admin), as: :json

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal Account.count, body.dig("data", "totals", "accounts")
    account = body.dig("data", "accounts").find { |item| item["id"] == accounts(:one).id }
    assert_equal "active", account["subscription_status"]
    assert_equal "2026-05-01", account["subscription_starts_on"]
    assert_equal "2027-05-01", account["subscription_ends_on"]
    assert account["clinics"].any? { |clinic| clinic["id"] == clinics(:one).id }
  end

  test "clinic users cannot view platform overview" do
    get api_v1_platform_overview_url, headers: api_headers_for(users(:one)), as: :json

    assert_response :forbidden
  end
end
