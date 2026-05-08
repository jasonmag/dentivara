require "test_helper"

class ClinicSettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
  end

  test "should show clinic settings" do
    get clinic_settings_url

    assert_response :success
    assert_select "select[name='clinic_setting[time_zone]']"
  end

  test "should update clinic timezone" do
    patch clinic_settings_url, params: {
      clinic_setting: {
        time_zone: "America/New_York"
      }
    }

    assert_redirected_to clinic_settings_url
    assert_equal "America/New_York", ClinicSetting.current.reload.time_zone
  end
end
