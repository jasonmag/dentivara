require "test_helper"

class ApiV1PatientsTest < ActionDispatch::IntegrationTest
  test "rejects unauthorized access" do
    get api_v1_patients_url, as: :json
    assert_response :unauthorized
  end

  test "lists patients with valid token" do
    get api_v1_patients_url, headers: { "Authorization" => "Bearer dev-token" }, as: :json
    assert_response :success

    body = JSON.parse(response.body)
    assert body.is_a?(Array)
    assert body.first.key?("first_name")
  end
end
