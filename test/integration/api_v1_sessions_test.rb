require "test_helper"

class ApiV1SessionsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user.update!(role: :clinic_owner, password: "password123", password_confirmation: "password123")
    SubscriptionPlan.find_or_create_by!(code: "starter") do |plan|
      plan.name = "Starter"
      plan.price_per_month = 1490
      plan.clinics_included = 1
      plan.extra_clinic_price = 700
      plan.position = 1
    end
  end

  test "creates api token with valid credentials" do
    assert_difference("ApiAccessToken.count", 1) do
      post api_v1_session_url, params: {
        session: {
          email: @user.email,
          password: "password123",
          device_name: "iPhone 16"
        }
      }, as: :json
    end

    assert_response :created
    body = JSON.parse(response.body)
    assert body.dig("data", "token").present?
    assert_equal "Bearer", body.dig("data", "token_type")
    assert_equal @user.id, body.dig("data", "user", "id")
    assert_equal "2027-05-01", body.dig("data", "user", "account_subscription_ends_on")
    assert_equal false, body.dig("data", "user", "account_subscription_expired")
    assert_equal false, body.dig("data", "user", "account_can_add_clinic")
  end

  test "marks expired clinic owner subscription on login" do
    accounts(:one).update!(subscription_starts_on: "2025-01-01", subscription_ends_on: "2025-12-31")

    post api_v1_session_url, params: {
      session: {
        email: @user.email,
        password: "password123"
      }
    }, as: :json

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "2025-12-31", body.dig("data", "user", "account_subscription_ends_on")
    assert_equal true, body.dig("data", "user", "account_subscription_expired")
  end

  test "clinic owner can refresh current session without selected clinic context" do
    @user.update!(clinic: nil)

    get api_v1_session_url,
      headers: api_headers_for(@user),
      as: :json

    assert_response :success
    assert_equal "clinic_owner", response.parsed_body.dig("data", "user", "role")
  end

  test "rejects invalid credentials" do
    post api_v1_session_url, params: {
      session: {
        email: @user.email,
        password: "wrong-password"
      }
    }, as: :json

    assert_response :unauthorized
    assert_equal "invalid_credentials", JSON.parse(response.body).dig("error", "code")
  end

  test "revokes current api token" do
    access_token, raw_token = ApiAccessToken.generate!(user: @user, name: "Logout test")

    delete api_v1_session_url, headers: { "Authorization" => "Bearer #{raw_token}" }, as: :json
    assert_response :no_content
    assert access_token.reload.revoked_at.present?

    get api_v1_patients_url, headers: { "Authorization" => "Bearer #{raw_token}" }, as: :json
    assert_response :unauthorized
  end
end
