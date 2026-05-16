require "test_helper"

class ApiV1UsersTest < ActionDispatch::IntegrationTest
  test "account owner sees personnel from clinics under their account" do
    account = accounts(:one)
    owner = User.create!(
      account_only: true,
      name: "Account Owner",
      email: "account-owner-users@example.com",
      role: :clinic_owner,
      password: "password123",
      password_confirmation: "password123"
    )
    AccountMembership.create!(account: account, user: owner, role: "owner", accepted_at: Time.current)
    dentist = User.create!(
      clinic: clinics(:one),
      name: "Clinic Dentist",
      email: "clinic-dentist-users@example.com",
      role: :dentist,
      password: "password123",
      password_confirmation: "password123"
    )

    get api_v1_users_url, headers: api_headers_for(owner), as: :json

    assert_response :success
    emails = JSON.parse(response.body)["data"].map { |user| user["email"] }
    assert_includes emails, dentist.email
    assert_not_includes emails, owner.email
  end
end
