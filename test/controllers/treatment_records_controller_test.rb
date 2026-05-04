require "test_helper"

class TreatmentRecordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @treatment_record = treatment_records(:one)
  end

  test "should get index" do
    get treatment_records_url
    assert_response :success
  end

  test "should get new" do
    get new_treatment_record_url
    assert_response :success
  end

  test "should create treatment_record" do
    assert_difference("TreatmentRecord.count") do
      post treatment_records_url, params: { treatment_record: { appointment_id: @treatment_record.appointment_id, clinical_notes: @treatment_record.clinical_notes, cost: @treatment_record.cost, patient_id: @treatment_record.patient_id, performed_on: @treatment_record.performed_on, service_type: @treatment_record.service_type, user_id: @treatment_record.user_id } }
    end

    assert_redirected_to treatment_record_url(TreatmentRecord.last)
  end

  test "should show treatment_record" do
    get treatment_record_url(@treatment_record)
    assert_response :success
  end

  test "should get edit" do
    get edit_treatment_record_url(@treatment_record)
    assert_response :success
  end

  test "should update treatment_record" do
    patch treatment_record_url(@treatment_record), params: { treatment_record: { appointment_id: @treatment_record.appointment_id, clinical_notes: @treatment_record.clinical_notes, cost: @treatment_record.cost, patient_id: @treatment_record.patient_id, performed_on: @treatment_record.performed_on, service_type: @treatment_record.service_type, user_id: @treatment_record.user_id } }
    assert_redirected_to treatment_record_url(@treatment_record)
  end

  test "should destroy treatment_record" do
    assert_difference("TreatmentRecord.count", -1) do
      delete treatment_record_url(@treatment_record)
    end

    assert_redirected_to treatment_records_url
  end
end
