require "test_helper"

class ApiV1ClinicOnboardingTest < ActionDispatch::IntegrationTest
  test "creates clinic workspace with owner and default services" do
    assert_difference([ "Clinic.count", "User.count" ], 1) do
      post api_v1_clinic_onboarding_url,
        params: {
          onboarding: {
            clinic: {
              name: "Northside Dental",
              contact_email: "hello@northside.test",
              phone: "09170000000",
              currency_code: "PHP"
            },
            owner: {
              name: "Northside Owner",
              email: "owner@northside.test",
              password: "password123"
            }
          }
        },
        as: :json
    end

    assert_response :created
    body = JSON.parse(response.body)
    clinic = Clinic.find(body.dig("data", "clinic", "id"))
    owner = User.find(body.dig("data", "user", "id"))

    assert_equal clinic, owner.clinic
    assert_equal "clinic_owner", owner.role
    assert_equal 3, clinic.clinic_services.count
    assert_equal "trialing", clinic.subscription_status
    assert body.dig("data", "token").present?
  end
end
