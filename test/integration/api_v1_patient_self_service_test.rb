require "test_helper"

class ApiV1PatientSelfServiceTest < ActionDispatch::IntegrationTest
  test "patient can register for free and claim a clinic patient record" do
    patient = patients(:one)

    assert_difference("User.patient.count", 1) do
      post api_v1_patient_registration_url, params: {
        patient_registration: {
          name: "Juan Portal",
          email: "juan.portal@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }, as: :json
    end

    assert_response :created
    token = JSON.parse(response.body).dig("data", "token")

    assert_difference("PatientLink.count", 1) do
      post api_v1_patient_claim_url,
        headers: { "Authorization" => "Bearer #{token}" },
        params: { patient_claim: { claim_code: patient.claim_code.downcase } },
        as: :json
    end

    assert_response :created
    patient.reload
    assert_equal "juan.portal@example.com", patient.user.email
    assert patient.claimed_at.present?
  end

  test "staff users cannot claim patient records" do
    post api_v1_patient_claim_url,
      headers: api_headers_for(users(:one)),
      params: { patient_claim: { claim_code: patients(:one).claim_code } },
      as: :json

    assert_response :forbidden
  end

  test "patient portal lists linked records without requiring a paid subscription" do
    get api_v1_patient_portal_url, headers: api_headers_for(users(:four)), as: :json

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal [ patients(:two).id ], body.dig("data", "linked_patients").map { |item| item.dig("patient", "id") }
  end

  test "patient can claim record from email invite without sms otp" do
    patient = patients(:one)
    invite, raw_token = PatientClaimInvite.issue!(patient)

    assert_difference([ "User.patient.count", "PatientLink.count" ], 1) do
      post api_v1_patient_claim_invite_claim_url,
        params: {
          patient_claim_invite_claim: {
            token: raw_token,
            last_name: patient.last_name.downcase,
            birth_date: patient.birth_date.iso8601,
            phone_last4: patient.phone.last(4),
            password: "password123",
            password_confirmation: "password123"
          }
        },
        as: :json
    end

    assert_response :created
    assert_equal patient.email, response.parsed_body.dig("data", "user", "email")
    assert_equal patient.id, response.parsed_body.dig("data", "patient", "id")
    assert invite.reload.claimed_at.present?
    assert patient.reload.claimed_at.present?
  end

  test "patient invite claim rejects mismatched identity details" do
    _invite, raw_token = PatientClaimInvite.issue!(patients(:one))

    assert_no_difference([ "User.patient.count", "PatientLink.count" ]) do
      post api_v1_patient_claim_invite_claim_url,
        params: {
          patient_claim_invite_claim: {
            token: raw_token,
            last_name: "Wrong",
            birth_date: patients(:one).birth_date.iso8601,
            phone_last4: patients(:one).phone.last(4),
            password: "password123",
            password_confirmation: "password123"
          }
        },
        as: :json
    end

    assert_response :unprocessable_entity
    assert_equal "identity_verification_failed", response.parsed_body.dig("error", "code")
  end

  test "clinic staff can send patient portal invite by email" do
    assert_difference("PatientClaimInvite.count", 1) do
      post api_v1_patient_claim_invites_url,
        headers: api_headers_for(users(:one)),
        params: { patient_claim_invite: { patient_id: patients(:one).id } },
        as: :json
    end

    assert_response :created
    assert_equal patients(:one).id, response.parsed_body.dig("data", "patient_id")
  end
end
