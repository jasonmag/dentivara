require "application_system_test_case"

class TreatmentRecordsTest < ApplicationSystemTestCase
  setup do
    @treatment_record = treatment_records(:one)
  end

  test "visiting the index" do
    visit treatment_records_url
    assert_selector "h1", text: "Treatment records"
  end

  test "should create treatment record" do
    visit treatment_records_url
    click_on "New treatment record"

    fill_in "Appointment", with: @treatment_record.appointment_id
    fill_in "Clinical notes", with: @treatment_record.clinical_notes
    fill_in "Cost", with: @treatment_record.cost
    fill_in "Patient", with: @treatment_record.patient_id
    fill_in "Performed on", with: @treatment_record.performed_on
    fill_in "Service type", with: @treatment_record.service_type
    fill_in "User", with: @treatment_record.user_id
    click_on "Create Treatment record"

    assert_text "Treatment record was successfully created"
    click_on "Back"
  end

  test "should update Treatment record" do
    visit treatment_record_url(@treatment_record)
    click_on "Edit this treatment record", match: :first

    fill_in "Appointment", with: @treatment_record.appointment_id
    fill_in "Clinical notes", with: @treatment_record.clinical_notes
    fill_in "Cost", with: @treatment_record.cost
    fill_in "Patient", with: @treatment_record.patient_id
    fill_in "Performed on", with: @treatment_record.performed_on
    fill_in "Service type", with: @treatment_record.service_type
    fill_in "User", with: @treatment_record.user_id
    click_on "Update Treatment record"

    assert_text "Treatment record was successfully updated"
    click_on "Back"
  end

  test "should destroy Treatment record" do
    visit treatment_record_url(@treatment_record)
    click_on "Destroy this treatment record", match: :first

    assert_text "Treatment record was successfully destroyed"
  end
end
