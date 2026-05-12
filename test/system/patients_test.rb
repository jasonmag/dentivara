require "application_system_test_case"

class PatientsTest < ApplicationSystemTestCase
  setup do
    @patient = patients(:one)
  end

  test "visiting the index" do
    visit patients_url
    assert_selector "h1", text: "Patients"
  end

  test "should create patient" do
    visit patients_url
    click_on "New patient"

    fill_in "Birth date", with: @patient.birth_date
    fill_in "Consented at", with: @patient.consented_at
    fill_in "Email", with: @patient.email
    fill_in "Emergency contact name", with: @patient.emergency_contact_name
    fill_in "Emergency contact phone", with: @patient.emergency_contact_phone
    fill_in "First name", with: @patient.first_name
    fill_in "Last name", with: @patient.last_name
    fill_in "Medical history", with: @patient.medical_history
    fill_in "Phone", with: @patient.phone
    click_on "Create Patient"

    assert_text "Patient was successfully created"
    click_on "Back"
  end

  test "should update Patient" do
    visit patient_url(@patient)
    click_on "Edit this patient", match: :first

    fill_in "Birth date", with: @patient.birth_date
    fill_in "Consented at", with: @patient.consented_at.to_s
    fill_in "Email", with: @patient.email
    fill_in "Emergency contact name", with: @patient.emergency_contact_name
    fill_in "Emergency contact phone", with: @patient.emergency_contact_phone
    fill_in "First name", with: @patient.first_name
    fill_in "Last name", with: @patient.last_name
    fill_in "Medical history", with: @patient.medical_history
    fill_in "Phone", with: @patient.phone
    click_on "Update Patient"

    assert_text "Patient was successfully updated"
    click_on "Back"
  end

  test "should destroy Patient" do
    visit patient_url(@patient)
    click_on "Destroy this patient", match: :first

    assert_text "Patient was successfully destroyed"
  end
end
