require "test_helper"

class ApiV1PlatformSettingsTest < ActionDispatch::IntegrationTest
  setup do
    @system_admin = User.create!(
      clinic: clinics(:one),
      name: "Platform Settings Admin",
      email: "platform-settings-admin@example.com",
      role: :system_admin,
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "system admin updates platform currency" do
    get api_v1_platform_settings_url, headers: api_headers_for(@system_admin), as: :json
    assert_response :success
    assert_includes response.parsed_body.dig("data", "currency_options").map { |option| option.fetch("code") }, "PHP"

    patch api_v1_platform_settings_url,
      headers: api_headers_for(@system_admin),
      params: { platform_setting: { currency_code: "PHP" } },
      as: :json

    assert_response :success
    assert_equal "PHP", response.parsed_body.dig("data", "currency_code")
    assert_equal "PHP", ClinicSetting.for_clinic(@system_admin.clinic).first.currency_code
  end
end
