require "test_helper"

class ScheduleSettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
  end

  test "should show schedule settings" do
    get schedule_settings_url
    assert_response :success
  end

  test "should create clinic schedule" do
    assert_difference("ClinicSchedule.count") do
      post clinic_schedules_schedule_settings_url, params: {
        clinic_schedule: {
          day_of_week: 1,
          opens_at: "08:00",
          closes_at: "17:00",
          max_concurrent_appointments: 2
        }
      }
    end

    assert_redirected_to schedule_settings_url
  end

  test "should destroy clinic schedule" do
    schedule = ClinicSchedule.create!(day_of_week: 2, opens_at: "08:00", closes_at: "17:00", max_concurrent_appointments: 2)

    assert_difference("ClinicSchedule.count", -1) do
      delete clinic_schedule_schedule_settings_url(schedule)
    end

    assert_redirected_to schedule_settings_url
  end

  test "should destroy clinic closure" do
    closure = ClinicClosure.create!(date: Date.new(2026, 6, 16), reason: "Holiday")

    assert_difference("ClinicClosure.count", -1) do
      delete clinic_closure_schedule_settings_url(closure)
    end

    assert_redirected_to schedule_settings_url
  end

  test "should create dentist schedule" do
    assert_difference("DentistSchedule.count") do
      post dentist_schedules_schedule_settings_url, params: {
        dentist_schedule: {
          user_id: users(:one).id,
          day_of_week: 1,
          starts_at: "09:00",
          ends_at: "16:00",
          active: "1"
        }
      }
    end

    assert_redirected_to schedule_settings_url
  end

  test "should destroy dentist schedule" do
    schedule = DentistSchedule.create!(user: users(:one), day_of_week: 3, starts_at: "09:00", ends_at: "16:00")

    assert_difference("DentistSchedule.count", -1) do
      delete dentist_schedule_schedule_settings_url(schedule)
    end

    assert_redirected_to schedule_settings_url
  end

  test "should destroy dentist override" do
    override = DentistScheduleOverride.create!(user: users(:one), date: Date.new(2026, 6, 17), unavailable: true)

    assert_difference("DentistScheduleOverride.count", -1) do
      delete dentist_override_schedule_settings_url(override)
    end

    assert_redirected_to schedule_settings_url
  end
end
