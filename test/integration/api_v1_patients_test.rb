require "test_helper"

class ApiV1PatientsTest < ActionDispatch::IntegrationTest
  setup do
    @previous_token = ENV["API_V1_TOKEN"]
    ENV["API_V1_TOKEN"] = nil
    @headers = api_headers_for(users(:one))
  end

  teardown do
    ENV["API_V1_TOKEN"] = @previous_token
  end

  test "rejects unauthorized access" do
    get api_v1_patients_url, as: :json
    assert_response :unauthorized
    assert_equal "unauthorized", JSON.parse(response.body).dig("error", "code")
  end

  test "lists patients with valid api token and pagination metadata" do
    get api_v1_patients_url, headers: @headers, params: { per_page: 1 }, as: :json
    assert_response :success

    body = JSON.parse(response.body)
    assert body["data"].is_a?(Array)
    assert_equal 1, body["data"].length
    assert body.dig("data", 0).key?("first_name")
    assert_equal 1, body.dig("meta", "pagination", "per_page")
  end

  test "filters patients by search" do
    get api_v1_patients_url, headers: @headers, params: { search: "Liza" }, as: :json
    assert_response :success

    names = JSON.parse(response.body)["data"].map { |patient| patient["full_name"] }
    assert_equal [ "Liza Santos" ], names
  end

  test "rejects revoked api token" do
    access_token, raw_token = ApiAccessToken.generate!(user: users(:one), name: "Revoked client")
    access_token.revoke!

    get api_v1_patients_url, headers: { "Authorization" => "Bearer #{raw_token}" }, as: :json
    assert_response :unauthorized
  end

  test "rejects users without api permission" do
    get api_v1_patients_url, headers: api_headers_for(users(:four)), as: :json
    assert_response :forbidden
    assert_equal "forbidden", JSON.parse(response.body).dig("error", "code")
  end

  test "returns normalized validation errors" do
    post api_v1_patients_url, headers: @headers, params: { patient: { first_name: "", last_name: "", phone: "" } }, as: :json
    assert_response :unprocessable_entity

    body = JSON.parse(response.body)
    assert_equal "validation_failed", body.dig("error", "code")
    assert body.dig("error", "details").key?("first_name")
  end

  test "creates claim invite when patient is created with email" do
    assert_difference("PatientClaimInvite.count", 1) do
      post api_v1_patients_url,
        headers: @headers,
        params: {
          patient: {
            first_name: "Invite",
            last_name: "Patient",
            birth_date: "1990-01-02",
            phone: "09170000001",
            email: "invite-patient@example.com"
          }
        },
        as: :json
    end

    assert_response :created
    assert_equal response.parsed_body.dig("data", "id"), PatientClaimInvite.last.patient_id
  end
end
