require "test_helper"

class ApiV1ClinicsTest < ActionDispatch::IntegrationTest
  setup do
    @system_admin = User.create!(
      clinic: clinics(:one),
      name: "Clinic API Admin",
      email: "clinic-api-admin@example.com",
      role: :system_admin,
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "system admin creates clinic under an account with active inactive status" do
    assert_difference("Clinic.count", 1) do
      post api_v1_clinics_url,
        headers: api_headers_for(@system_admin),
        params: {
          clinic: {
            account_id: accounts(:one).id,
            name: "Branch Dental",
            contact_email: "branch@example.com",
            subscription_status: "inactive"
          }
        },
        as: :json
    end

    assert_response :created
    clinic = Clinic.find(JSON.parse(response.body).dig("data", "id"))
    assert_equal accounts(:one), clinic.account
    assert_equal accounts(:one).subscription_plan, clinic.subscription_plan
    assert_equal "inactive", clinic.subscription_status
  end
end
