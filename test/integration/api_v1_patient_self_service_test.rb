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
end
