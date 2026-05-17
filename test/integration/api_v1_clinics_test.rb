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
    assert_equal 1, response.parsed_body.dig("error", "details", "clinics_included")
    assert_equal 1, response.parsed_body.dig("error", "details", "clinics_count")
    assert_equal 0, response.parsed_body.dig("error", "details", "clinics_remaining")
    assert_equal false, response.parsed_body.dig("error", "details", "can_add_clinic")
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

  test "clinic owner can delete clinic under their account" do
    clinic = Clinic.create!(
      account: accounts(:one),
      name: "Owner Deleted Branch",
      contact_email: "owner-deleted@example.com",
      subscription_status: "active"
    )

    delete api_v1_clinic_url(clinic),
      headers: api_headers_for(@owner),
      as: :json

    assert_response :no_content
    assert_equal "inactive", clinic.reload.subscription_status
    assert_not_nil clinic.suspended_at
    assert_not_nil clinic.archived_at
  end

  test "clinic owner can delete directly accessible clinic without account membership" do
    AccountMembership.where(user: @owner).delete_all
    clinic = clinics(:one)

    delete api_v1_clinic_url(clinic),
      headers: api_headers_for(@owner),
      as: :json

    assert_response :no_content
    assert_not_nil clinic.reload.archived_at
  end

  test "account owner can delete clinic without selected clinic context" do
    @owner.update_column(:clinic_id, nil)
    clinic = clinics(:one)

    delete api_v1_clinic_url(clinic),
      headers: api_headers_for(@owner),
      as: :json

    assert_response :no_content
    assert_not_nil clinic.reload.archived_at
  end

  test "clinic owner can activate archived clinic when subscription has provision" do
    @starter_plan.update!(clinics_included: 2)
    clinic = Clinic.create!(
      account: accounts(:one),
      name: "Archived Reactivation Branch",
      contact_email: "reactivation@example.com",
      subscription_status: "inactive",
      suspended_at: Time.current,
      archived_at: Time.current
    )

    patch activate_api_v1_clinic_url(clinic),
      headers: api_headers_for(@owner),
      as: :json

    assert_response :success
    clinic.reload
    assert_equal "active", clinic.subscription_status
    assert_nil clinic.suspended_at
    assert_nil clinic.archived_at
  end

  test "clinic owner cannot activate archived clinic beyond subscription provision" do
    @starter_plan.update!(clinics_included: 1)
    clinic = Clinic.create!(
      account: accounts(:one),
      name: "Blocked Reactivation Branch",
      contact_email: "blocked-reactivation@example.com",
      subscription_status: "inactive",
      suspended_at: Time.current,
      archived_at: Time.current
    )

    patch activate_api_v1_clinic_url(clinic),
      headers: api_headers_for(@owner),
      as: :json

    assert_response :unprocessable_entity
    assert_equal "clinic_limit_reached", response.parsed_body.dig("error", "code")
    assert_equal 1, response.parsed_body.dig("error", "details", "clinics_included")
    assert_equal 1, response.parsed_body.dig("error", "details", "clinics_count")
    assert_not_nil clinic.reload.archived_at
  end

  test "clinic owner cannot delete clinic from another account" do
    delete api_v1_clinic_url(clinics(:two)),
      headers: api_headers_for(@owner),
      as: :json

    assert_response :forbidden
  end

  test "clinic owner clinic limit uses current active subscription instead of pending account request" do
    @starter_plan.update!(clinics_included: 2)
    accounts(:one).account_subscriptions.create!(
      subscription_plan: "starter",
      subscription_status: "active",
      subscription_starts_on: "2026-01-01",
      subscription_ends_on: "2027-01-01"
    )
    accounts(:one).update!(
      subscription_plan: "growing",
      subscription_status: "inactive",
      subscription_starts_on: "2026-05-17",
      subscription_ends_on: "2027-05-17"
    )

    assert_difference("Clinic.count", 1) do
      post api_v1_clinics_url,
        headers: api_headers_for(@owner),
        params: {
          clinic: {
            name: "Active Subscription Branch",
            contact_email: "active-subscription@example.com",
            subscription_status: "active"
          }
        },
        as: :json
    end

    assert_response :created
  end
end
