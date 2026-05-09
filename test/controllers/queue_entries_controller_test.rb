require "test_helper"

class QueueEntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
  end

  test "should get index" do
    get queue_entries_url
    assert_response :success
    assert_match "Reception Queue Board", response.body
  end

  test "should create queue entry and check in appointment" do
    appointment = appointments(:one)
    assert_difference("QueueEntry.count", 1) do
      post queue_entries_url, params: {
        queue_entry: {
          appointment_id: appointment.id,
          patient_id: appointment.patient_id,
          queue_type: "scheduled",
          priority_level: 1
        }
      }
    end

    assert_redirected_to queue_entries_url
    assert_equal "checked_in", appointment.reload.status
  end

  test "call next should update entry and appointment status" do
    appointment = appointments(:one)
    appointment.update!(status: "confirmed")
    QueueEntry.create!(appointment: appointment, patient: appointment.patient, queue_type: "scheduled", priority_level: 3, status: "waiting", arrived_at: Time.current)

    post call_next_queue_entries_url

    assert_redirected_to queue_entries_url
    entry = QueueEntry.last
    assert_equal "called", entry.status
    assert_equal "checked_in", appointment.reload.status
  end

  test "serve action should transition called entry" do
    appointment = appointments(:one)
    appointment.update!(status: "checked_in")
    entry = QueueEntry.create!(appointment: appointment, patient: appointment.patient, queue_type: "scheduled", priority_level: 2, status: "called", arrived_at: Time.current, called_at: Time.current)

    patch serve_queue_entry_url(entry)

    assert_redirected_to queue_entries_url
    assert_equal "served", entry.reload.status
    assert_equal "in_progress", appointment.reload.status
  end
end
