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
        time_zone: "America/New_York",
        currency_code: "PHP",
        queue_eta_minutes_default: 22,
        queue_eta_minutes_scheduled: 18,
        queue_eta_minutes_walk_in: 24,
        queue_eta_minutes_emergency: 9,
        queue_eta_minutes_priority: 14
      }
    }

    assert_redirected_to clinic_settings_url
    setting = ClinicSetting.current.reload
    assert_equal "America/New_York", setting.time_zone
    assert_equal "PHP", setting.currency_code
    assert_equal 22, setting.queue_eta_minutes_default
    assert_equal 18, setting.queue_eta_minutes_scheduled
    assert_equal 24, setting.queue_eta_minutes_walk_in
    assert_equal 9, setting.queue_eta_minutes_emergency
    assert_equal 14, setting.queue_eta_minutes_priority
  end
end
