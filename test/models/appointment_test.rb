require "test_helper"

class AppointmentTest < ActiveSupport::TestCase
  test "assigns any available dentist when provider is blank" do
    starts_at = Time.zone.local(2026, 6, 15, 14, 0)

    appointment = Appointment.new(
      patient: patients(:one),
      source: "online",
      booking_type: "scheduled",
      starts_at: starts_at,
      ends_at: starts_at + 30.minutes,
      status: "pending"
    )

    assert appointment.valid?
    assert_equal users(:one), appointment.user
  end

  test "blocks dentist overlap including buffer time" do
    starts_at = appointments(:one).ends_at + 5.minutes

    appointment = Appointment.new(
      patient: patients(:two),
      user: users(:one),
      source: "phone",
      booking_type: "scheduled",
      starts_at: starts_at,
      ends_at: starts_at + 30.minutes,
      status: "confirmed"
    )

    assert_not appointment.valid?
    assert_includes appointment.errors[:base], "Dentist is not available in the selected time slot"
  end

  test "blocks new appointments in the past" do
    starts_at = 1.hour.ago

    appointment = Appointment.new(
      patient: patients(:one),
      user: users(:one),
      source: "phone",
      booking_type: "scheduled",
      starts_at: starts_at,
      ends_at: starts_at + 30.minutes,
      status: "pending"
    )

    assert_not appointment.valid?
    assert_includes appointment.errors[:starts_at], "cannot be in the past"
  end

  test "blocks non emergency appointments on clinic closure dates" do
    closed_date = Date.new(2026, 6, 16)
    ClinicClosure.create!(date: closed_date, reason: "Holiday")
    starts_at = Time.zone.local(2026, 6, 16, 10, 0)

    appointment = Appointment.new(
      patient: patients(:one),
      user: users(:one),
      source: "phone",
      booking_type: "scheduled",
      starts_at: starts_at,
      ends_at: starts_at + 30.minutes,
      status: "pending"
    )

    assert_not appointment.valid?
    assert_includes appointment.errors[:base], "Clinic is not open for the selected time"
  end

  test "honors dentist working hours when schedules are configured" do
    DentistSchedule.create!(user: users(:one), day_of_week: 1, starts_at: "10:00", ends_at: "12:00")
    starts_at = Time.zone.local(2026, 6, 15, 9, 0)

    appointment = Appointment.new(
      patient: patients(:one),
      user: users(:one),
      source: "phone",
      booking_type: "scheduled",
      starts_at: starts_at,
      ends_at: starts_at + 30.minutes,
      status: "pending"
    )

    assert_not appointment.valid?
    assert_includes appointment.errors[:base], "Dentist is not available in the selected time slot"
  end

  test "available slots stay within clinic schedule hours" do
    target_date = Date.new(2026, 6, 17)
    ClinicSchedule.create!(day_of_week: target_date.wday, opens_at: "10:00", closes_at: "11:00", max_concurrent_appointments: 2)

    slots = AppointmentScheduler.new(date: target_date, duration_minutes: 30, buffer_minutes: 0).slots(limit: 10)

    assert slots.any?
    assert slots.all? { |slot| slot[:starts_at].hour == 10 && slot[:ends_at].hour <= 11 }
  end

  test "available slots include the full clinic availability window" do
    target_date = Date.new(2026, 6, 17)
    ClinicSchedule.create!(day_of_week: target_date.wday, opens_at: "10:00", closes_at: "12:00", max_concurrent_appointments: 2)

    slots = AppointmentScheduler.new(date: target_date, duration_minutes: 30, buffer_minutes: 0).slots

    assert_equal 7, slots.size
    assert_equal "10:00", slots.first[:starts_at].strftime("%H:%M")
    assert_equal "11:30", slots.last[:starts_at].strftime("%H:%M")
  end

  test "available slots are empty when clinic schedules exist but no rule matches the day" do
    target_date = Date.new(2026, 6, 17)
    ClinicSchedule.create!(day_of_week: 1, opens_at: "10:00", closes_at: "12:00", max_concurrent_appointments: 2)

    slots = AppointmentScheduler.new(date: target_date, duration_minutes: 30, buffer_minutes: 0).slots

    assert_empty slots
  end

  test "available slots are empty on clinic closures" do
    target_date = Date.new(2026, 6, 18)
    ClinicClosure.create!(date: target_date, reason: "Holiday")

    slots = AppointmentScheduler.new(date: target_date).slots(limit: 10)

    assert_empty slots
  end

  test "available slots require dentist working hours once schedules exist" do
    dentist = users(:one)
    target_date = Date.new(2026, 6, 18)
    DentistSchedule.create!(user: dentist, day_of_week: 1, starts_at: "09:00", ends_at: "16:00")

    slots = AppointmentScheduler.new(date: target_date, preferred_user: dentist).slots(limit: 10)

    assert_empty slots
  end

  test "available slots honor dentist unavailable overrides" do
    dentist = users(:one)
    target_date = Date.new(2026, 6, 19)
    DentistSchedule.create!(user: dentist, day_of_week: target_date.wday, starts_at: "09:00", ends_at: "16:00")
    DentistScheduleOverride.create!(user: dentist, date: target_date, unavailable: true, reason: "Leave")

    slots = AppointmentScheduler.new(date: target_date, preferred_user: dentist).slots(limit: 10)

    assert_empty slots
  end

  test "available slots honor dentist partial-day overrides" do
    dentist = users(:one)
    target_date = Date.new(2026, 6, 19)
    DentistSchedule.create!(user: dentist, day_of_week: target_date.wday, starts_at: "09:00", ends_at: "16:00")
    DentistScheduleOverride.create!(user: dentist, date: target_date, available_from: "13:00", available_until: "15:00")

    slots = AppointmentScheduler.new(date: target_date, preferred_user: dentist, duration_minutes: 30, buffer_minutes: 0).slots(limit: 10)

    assert slots.any?
    assert slots.all? { |slot| slot[:starts_at].hour >= 13 && slot[:ends_at].hour <= 15 }
  end
end
