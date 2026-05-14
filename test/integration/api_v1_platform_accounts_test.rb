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

  test "system admin creates a new client account with owner and clinic" do
    assert_difference([ "Account.count", "Clinic.count", "User.clinic_owner.count" ], 1) do
      post api_v1_platform_accounts_url,
        headers: api_headers_for(@system_admin),
        params: {
          platform_account: {
            account: {
              name: "North Dental Group",
              slug: "north-dental-group",
              billing_email: "billing@north.example",
              subscription_plan: "clinic",
              subscription_status: "active",
              subscription_starts_on: "2026-05-01",
              subscription_ends_on: "2027-05-01"
            },
            clinic: {
              name: "North Dental Clinic",
              slug: "north-dental-clinic",
              contact_email: "frontdesk@north.example",
              phone: "09170001111",
              subscription_plan: "clinic"
            },
            owner: {
              name: "North Owner",
              email: "owner@north.example",
              password: "password123"
            }
          }
        },
        as: :json
    end

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "North Dental Group", body.dig("data", "account", "name")
    assert_equal "owner@north.example", body.dig("data", "owner", "email")
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
