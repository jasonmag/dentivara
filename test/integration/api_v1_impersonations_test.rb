require "test_helper"

class ApiV1ImpersonationsTest < ActionDispatch::IntegrationTest
  setup do
    @system_admin = User.create!(
      clinic: clinics(:one),
      name: "Impersonation Admin",
      email: "impersonation-admin@example.com",
      role: :system_admin,
      password: "password123",
      password_confirmation: "password123"
    )
    @owner = User.create!(
      clinic: clinics(:one),
      name: "Clinic Owner",
      email: "clinic-owner-impersonated@example.com",
      role: :clinic_owner,
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "system admin can create an impersonation token for clinic owner" do
    post api_v1_impersonation_url,
      headers: api_headers_for(@system_admin),
      params: { impersonation: { user_id: @owner.id, clinic_id: clinics(:one).id, reason: "support" } },
      as: :json

    assert_response :created
    body = JSON.parse(response.body)
    assert body.dig("data", "token").present?
    assert_equal @owner.id, body.dig("data", "user", "id")
    assert_equal @system_admin.id, ApiAccessToken.order(:created_at).last.impersonated_by_user_id
  end

  test "non system admin cannot impersonate" do
    post api_v1_impersonation_url,
      headers: api_headers_for(users(:one)),
      params: { impersonation: { user_id: @owner.id } },
      as: :json

    assert_response :forbidden
  end
end
