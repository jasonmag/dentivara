require "test_helper"

class ApiV1PatientsTest < ActionDispatch::IntegrationTest
  setup do
    @previous_token = ENV["API_V1_TOKEN"]
  end

  teardown do
    ENV["API_V1_TOKEN"] = @previous_token
  end

  test "rejects unauthorized access" do
    get api_v1_patients_url, as: :json
    assert_response :unauthorized
  end

  test "lists patients with valid fallback token in test" do
    ENV["API_V1_TOKEN"] = nil

    get api_v1_patients_url, headers: { "Authorization" => "Bearer dev-token" }, as: :json
    assert_response :success

    body = JSON.parse(response.body)
    assert body.is_a?(Array)
    assert body.first.key?("first_name")
  end

  test "uses explicit API_V1_TOKEN when configured" do
    ENV["API_V1_TOKEN"] = "custom-token"

    get api_v1_patients_url, headers: { "Authorization" => "Bearer dev-token" }, as: :json
    assert_response :unauthorized

    get api_v1_patients_url, headers: { "Authorization" => "Bearer custom-token" }, as: :json
    assert_response :success
  end
end
