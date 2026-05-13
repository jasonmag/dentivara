require "test_helper"

class ApiV1ClinicServicesTest < ActionDispatch::IntegrationTest
  setup do
    @headers = api_headers_for(users(:one))
    @service = ClinicService.create!(
      clinic: users(:one).clinic,
      name: "Whitening Consultation",
      base_price: 1500,
      duration_minutes: 30,
      preparation_minutes: 5,
      color: "#0ea5e9",
      active: true
    )
  end

  test "lists clinic services" do
    get api_v1_clinic_services_url, headers: @headers, as: :json
    assert_response :success

    body = JSON.parse(response.body)
    assert body["data"].any? { |service| service["id"] == @service.id && service["color"] == "#0ea5e9" }
  end

  test "creates clinic service" do
    assert_difference("ClinicService.count", 1) do
      post api_v1_clinic_services_url,
        headers: @headers,
        params: {
          clinic_service: {
            name: "Implant Consultation",
            base_price: 2500,
            duration_minutes: 45,
            preparation_minutes: 10,
            color: "#2a9d8f",
            active: true
          }
        },
        as: :json
    end

    assert_response :created
    assert_equal "#2a9d8f", JSON.parse(response.body).dig("data", "color")
  end

  test "updates clinic service" do
    patch api_v1_clinic_service_url(@service),
      headers: @headers,
      params: { clinic_service: { color: "#ef4444", active: false } },
      as: :json

    assert_response :success
    assert_equal "#ef4444", JSON.parse(response.body).dig("data", "color")
    assert_not @service.reload.active
  end

  test "deletes clinic service" do
    assert_difference("ClinicService.count", -1) do
      delete api_v1_clinic_service_url(@service), headers: @headers, as: :json
    end

    assert_response :no_content
  end

  test "returns validation errors" do
    post api_v1_clinic_services_url,
      headers: @headers,
      params: { clinic_service: { name: "", color: "blue" } },
      as: :json

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert_equal "validation_failed", body.dig("error", "code")
    assert body.dig("error", "details").key?("color")
  end
end
