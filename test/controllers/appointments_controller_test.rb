require "test_helper"

class AppointmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @appointment = appointments(:one)
    sign_in_as(users(:one))
  end

  test "should get index" do
    get appointments_url
    assert_response :success
    assert_select "div[data-controller='appointment-modal']"
    assert_select "button[data-action='appointment-modal#open']", minimum: 1
  end

  test "weekly schedule exposes next week navigation" do
    get appointments_url(date: "2026-06-15")

    assert_response :success
    assert_select "turbo-frame#weekly_schedule"
    assert_select "turbo-frame#weekly_schedule a[href='#{appointments_path(date: Date.new(2026, 6, 8).iso8601)}'][data-turbo-frame='weekly_schedule'][data-turbo-action='advance']"
    assert_select "turbo-frame#weekly_schedule a[href='#{appointments_path(date: Date.new(2026, 6, 22).iso8601)}'][data-turbo-frame='weekly_schedule'][data-turbo-action='advance']"
  end

  test "should get appointment details modal content" do
    get details_appointment_url(@appointment, week_date: @appointment.starts_at.to_date.iso8601)

    assert_response :success
    assert_match "Appointment Details", response.body
    assert_match "Save status", response.body
  end

  test "should get new" do
    get new_appointment_url
    assert_response :success
  end

  test "should get new with patient preselected" do
    get new_appointment_url(patient_id: patients(:two).id)

    assert_response :success
    assert_select "select[name='appointment[patient_id]'] option[selected][value=?]", patients(:two).id.to_s
  end

  test "available slots reflect the selected service duration preparation and buffer" do
    target_date = Time.zone.today.next_week(:monday)
    ClinicSchedule.create!(day_of_week: target_date.wday, opens_at: "10:00", closes_at: "12:00", max_concurrent_appointments: 2)
    service = ClinicService.create!(
      name: "Extended Procedure",
      base_price: 0,
      duration_minutes: 45,
      preparation_minutes: 15,
      active: true
    )

    get available_slots_appointments_url, params: {
      clinic_service_id: service.id,
      slot_date: target_date.to_s,
      slot_view: "week"
    }

    assert_response :success
    assert_match "Earliest Available Appointment", response.body
    assert_match "Recommended", response.body
    assert_select "button[data-slot-state='available']", true
  end

  test "available slots collapse into contiguous windows and split around booked time" do
    target_date = Date.new(2026, 6, 15)
    ClinicSchedule.create!(day_of_week: target_date.wday, opens_at: "08:00", closes_at: "17:00", max_concurrent_appointments: 1)
    service = ClinicService.create!(
      name: "Standard Procedure",
      base_price: 0,
      duration_minutes: 30,
      preparation_minutes: 0,
      active: true
    )

    Appointment.create!(
      patient: patients(:one),
      user: users(:one),
      source: "admin",
      booking_type: "scheduled",
      starts_at: Time.zone.local(2026, 6, 15, 11, 0),
      ends_at: Time.zone.local(2026, 6, 15, 11, 30),
      status: "confirmed",
      buffer_minutes: 0
    )

    get available_slots_appointments_url, params: {
      clinic_service_id: service.id,
      user_id: users(:one).id,
      slot_date: target_date.to_s,
      slot_view: "week"
    }

    assert_response :success
    assert_select "button[data-slot-state='available']"
    assert_match 'data-starts-at="2026-06-15T11:30"', response.body
    assert_match "more times", response.body
  end

  test "should create appointment" do
    starts_at = 7.days.from_now.change(hour: 15, min: 0)
    ends_at = starts_at + 45.minutes

    assert_difference("Appointment.count") do
      post appointments_url, params: {
        appointment: {
          booking_type: @appointment.booking_type,
          ends_at: ends_at,
          notes: @appointment.notes,
          patient_id: @appointment.patient_id,
          source: @appointment.source,
          starts_at: starts_at,
          status: @appointment.status,
          user_id: @appointment.user_id
        }
      }
    end

    assert_redirected_to appointment_url(Appointment.last)
  end

  test "should rerender new appointment form for invalid turbo stream submission" do
    assert_no_difference("Appointment.count") do
      post appointments_url(format: :turbo_stream), params: {
        appointment: {
          booking_type: "scheduled",
          source: "admin",
          status: "pending"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_match "New Appointment", response.body
  end

  test "should show appointment" do
    get appointment_url(@appointment)
    assert_response :success
  end

  test "should get edit" do
    get edit_appointment_url(@appointment)
    assert_response :success
  end

  test "should update appointment" do
    patch appointment_url(@appointment), params: { appointment: { booking_type: @appointment.booking_type, ends_at: @appointment.ends_at, notes: @appointment.notes, patient_id: @appointment.patient_id, source: @appointment.source, starts_at: @appointment.starts_at, status: @appointment.status, user_id: @appointment.user_id } }
    assert_redirected_to appointment_url(@appointment)
  end

  test "should update appointment from modal and refresh weekly schedule" do
    patch appointment_url(@appointment, format: :turbo_stream), params: {
      week_date: @appointment.starts_at.to_date.iso8601,
      appointment: {
        status: "confirmed"
      }
    }

    assert_response :success
    assert_match "weekly_schedule", response.body
    assert_match "Appointments by Day", response.body
  end

  test "should destroy appointment" do
    assert_difference("Appointment.count", -1) do
      delete appointment_url(@appointment)
    end

    assert_redirected_to appointments_url
  end
  end
