require "test_helper"

class ApiV1TenantScopeTest < ActionDispatch::IntegrationTest
  test "patients are scoped to authenticated user's clinic" do
    other_clinic = clinics(:two)
    other_user = User.create!(
      clinic: other_clinic,
      name: "Other Owner",
      email: "other-owner@example.com",
      role: :clinic_owner,
      password: "password123",
      password_confirmation: "password123"
    )
    Patient.create!(
      clinic: other_clinic,
      first_name: "Other",
      last_name: "Patient",
      phone: "09170000000"
    )

    get api_v1_patients_url, headers: api_headers_for(other_user), as: :json
    assert_response :success

    names = JSON.parse(response.body)["data"].map { |patient| patient["full_name"] }
    assert_equal [ "Other Patient" ], names
  end

  test "cross clinic records are not accessible" do
    other_patient = Patient.create!(
      clinic: clinics(:two),
      first_name: "Hidden",
      last_name: "Patient",
      phone: "09170000001"
    )

    get api_v1_patient_url(other_patient), headers: api_headers_for(users(:one)), as: :json

    assert_response :not_found
  end

  test "membership allows a user to switch clinics explicitly" do
    user = users(:one)
    other_clinic = clinics(:two)
    ClinicMembership.create!(clinic: other_clinic, user: user, role: :clinic_owner, accepted_at: Time.current)
    AccountMembership.create!(account: other_clinic.account, user: user, role: "owner", accepted_at: Time.current)
    Patient.create!(clinic: other_clinic, first_name: "Switched", last_name: "Patient", phone: "09170000002")

    get api_v1_patients_url, headers: api_headers_for(user, clinic: other_clinic), as: :json
    assert_response :success

    names = JSON.parse(response.body)["data"].map { |patient| patient["full_name"] }
    assert_equal [ "Switched Patient" ], names
  end

  test "invalid clinic context is forbidden instead of silently falling back" do
    get api_v1_patients_url, headers: api_headers_for(users(:one), clinic: clinics(:two)), as: :json

    assert_response :forbidden
    assert_equal "forbidden", JSON.parse(response.body).dig("error", "code")
  end
end
