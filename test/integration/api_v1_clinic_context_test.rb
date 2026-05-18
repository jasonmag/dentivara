require "test_helper"

class ApiV1ClinicContextTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:one)
    @owner.update!(role: :clinic_owner, password: "password123", password_confirmation: "password123")
  end

  test "clinic owner without selected clinic can open clinic under their account" do
    @owner.update_column(:clinic_id, nil)

    patch api_v1_clinic_context_url,
      headers: api_headers_for(@owner),
      params: { clinic_context: { clinic_id: clinics(:one).id } },
      as: :json

    assert_response :success
    assert_equal clinics(:one).id, response.parsed_body.dig("data", "clinic", "id")
  end

  test "clinic owner without selected clinic cannot open clinic from another account" do
    @owner.update_column(:clinic_id, nil)

    patch api_v1_clinic_context_url,
      headers: api_headers_for(@owner),
      params: { clinic_context: { clinic_id: clinics(:two).id } },
      as: :json

    assert_response :forbidden
    assert_equal "You are not authorized to access this clinic.", response.parsed_body.dig("error", "message")
  end
end
