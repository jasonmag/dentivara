require "test_helper"

class PatientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @patient = patients(:one)
  end

  test "should get index" do
    get patients_url
    assert_response :success
  end

  test "should get new" do
    get new_patient_url
    assert_response :success
  end

  test "should create patient" do
    assert_difference("Patient.count") do
      post patients_url, params: { patient: { birth_date: @patient.birth_date, consented_at: @patient.consented_at, email: @patient.email, emergency_contact_name: @patient.emergency_contact_name, emergency_contact_phone: @patient.emergency_contact_phone, first_name: @patient.first_name, last_name: @patient.last_name, medical_history: @patient.medical_history, phone: @patient.phone } }
    end

    assert_redirected_to patient_url(Patient.last)
  end

  test "should show patient" do
    get patient_url(@patient)
    assert_response :success
  end

  test "should get edit" do
    get edit_patient_url(@patient)
    assert_response :success
  end

  test "should update patient" do
    patch patient_url(@patient), params: { patient: { birth_date: @patient.birth_date, consented_at: @patient.consented_at, email: @patient.email, emergency_contact_name: @patient.emergency_contact_name, emergency_contact_phone: @patient.emergency_contact_phone, first_name: @patient.first_name, last_name: @patient.last_name, medical_history: @patient.medical_history, phone: @patient.phone } }
    assert_redirected_to patient_url(@patient)
  end

  test "should destroy patient" do
    assert_difference("Patient.count", -1) do
      delete patient_url(@patient)
    end

    assert_redirected_to patients_url
  end
end
