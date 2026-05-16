require "test_helper"

class ApiV1PlatformAccountsTest < ActionDispatch::IntegrationTest
  setup do
    @system_admin = User.create!(
      clinic: clinics(:one),
      name: "Platform Admin",
      email: "platform-accounts-admin@example.com",
      role: :system_admin,
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "system admin creates a new client account with organization owner only" do
    assert_difference("Account.count", 1) do
      assert_difference("User.clinic_owner.count", 1) do
        assert_no_difference([ "Clinic.count", "ClinicMembership.count" ]) do
          assert_difference("AccountMembership.count", 1) do
            post api_v1_platform_accounts_url,
              headers: api_headers_for(@system_admin),
              params: {
                platform_account: {
                  client_name: "North Dental Group",
                  client_email: "owner@north.example",
                  client_password: "password123",
                  client_password_confirmation: "password123"
                }
              },
              as: :json
          end
        end
      end
    end

    assert_response :created
    body = JSON.parse(response.body)
    assert_match(/\ACL-[A-Z0-9]{8}\z/, body.dig("data", "account", "client_number"))
    assert_equal "North Dental Group", body.dig("data", "account", "name")
    assert_nil body.dig("data", "clinic")
    assert_equal "owner@north.example", body.dig("data", "owner", "email")
    assert_equal "clinic_owner", body.dig("data", "owner", "role")
    assert_nil body.dig("data", "owner", "clinic_id")
    assert_equal "owner", Account.find(body.dig("data", "account", "id")).account_memberships.last.role
  end

  test "system admin cannot create client account when password confirmation does not match" do
    assert_no_difference([ "Account.count", "Clinic.count", "ClinicMembership.count", "User.clinic_owner.count" ]) do
      post api_v1_platform_accounts_url,
        headers: api_headers_for(@system_admin),
        params: {
          platform_account: {
            client_name: "Mismatch Dental Group",
            client_email: "owner-mismatch@north.example",
            client_password: "password123",
            client_password_confirmation: "different123"
          }
        },
        as: :json
    end

    assert_response :unprocessable_entity
    assert_equal "password_confirmation_mismatch", JSON.parse(response.body).dig("error", "code")
  end

  test "system admin updates account subscription window" do
    patch api_v1_platform_account_url(accounts(:one)),
      headers: api_headers_for(@system_admin),
      params: {
        account: {
          subscription_status: "active",
          subscription_starts_on: "2026-06-01",
          subscription_ends_on: "2027-06-01"
        }
      },
      as: :json

    assert_response :success
    assert_equal "2027-06-01", JSON.parse(response.body).dig("data", "subscription_ends_on")
  end
end
