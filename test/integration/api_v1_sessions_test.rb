require "test_helper"

class ApiV1SessionsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user.update!(password: "password123", password_confirmation: "password123")
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
