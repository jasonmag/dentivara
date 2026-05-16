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
    @owner = users(:one)
    @owner.update!(role: :clinic_owner, password: "password123", password_confirmation: "password123")
    @starter_plan = SubscriptionPlan.find_or_create_by!(code: "starter") do |plan|
      plan.name = "Starter"
      plan.price_per_month = 1490
      plan.clinics_included = 1
      plan.extra_clinic_price = 700
      plan.position = 1
    end
  end

  test "system admin creates clinic under an account with active inactive status" do
    assert_difference("Clinic.count", 1) do
      assert_no_difference("ClinicMembership.count") do
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
    end

    assert_response :created
    clinic = Clinic.find(JSON.parse(response.body).dig("data", "id"))
    assert_equal accounts(:one), clinic.account
    assert_equal accounts(:one).subscription_plan, clinic.subscription_plan
    assert_equal "inactive", clinic.subscription_status
  end

  test "clinic owner cannot create clinic when subscription clinic limit is reached" do
    accounts(:one).update!(
      subscription_plan: "starter",
      subscription_status: "active",
      subscription_starts_on: "2026-01-01",
      subscription_ends_on: "2027-01-01"
    )

    assert_no_difference("Clinic.count") do
      post api_v1_clinics_url,
        headers: api_headers_for(@owner),
        params: {
          clinic: {
            name: "Blocked Branch",
            contact_email: "blocked@example.com",
            subscription_status: "active"
          }
        },
        as: :json
    end

    assert_response :unprocessable_entity
    assert_equal "clinic_limit_reached", response.parsed_body.dig("error", "code")
  end

  test "clinic owner can create clinic when subscription clinic limit allows it" do
    @starter_plan.update!(clinics_included: 2)
    accounts(:one).update!(
      subscription_plan: "starter",
      subscription_status: "active",
      subscription_starts_on: "2026-01-01",
      subscription_ends_on: "2027-01-01"
    )

    assert_difference("Clinic.count", 1) do
      post api_v1_clinics_url,
        headers: api_headers_for(@owner),
        params: {
          clinic: {
            name: "Allowed Branch",
            contact_email: "allowed@example.com",
            subscription_status: "active"
          }
        },
        as: :json
    end

    assert_response :created
    assert_equal accounts(:one), Clinic.find(response.parsed_body.dig("data", "id")).account
  end
end
