require "test_helper"

class PrescriptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @patient = patients(:one)
    @template = DocumentTemplate.create!(
      name: "Rx Template",
      kind: "prescription",
      body_template: "Take medicine",
      active: true,
      default_for_prescription: true
    )
    @prescription = Prescription.create!(
      patient: @patient,
      document_template: @template,
      drafted_by_user: users(:one),
      issued_on: Date.current,
      body: "Sample body",
      status: "finalized"
    )
  end

  test "billing staff cannot open prescription index" do
    sign_in_as(users(:three))

    get patient_prescriptions_url(@patient)

    assert_redirected_to patient_url(@patient)
    follow_redirect!
    assert_match(/not authorized/i, response.body)
  end

  test "billing staff cannot sign prescription" do
    sign_in_as(users(:three))

    patch sign_patient_prescription_url(@patient, @prescription), params: {
      signature_data: "data:image/png;base64,AAAA",
      signature_confirmed: "1"
    }

    assert_redirected_to patient_url(@patient)
    @prescription.reload
    assert_equal "finalized", @prescription.status
  end

  test "dentist can sign finalized prescription" do
    sign_in_as(users(:one))

    patch sign_patient_prescription_url(@patient, @prescription), params: {
      signature_data: "data:image/png;base64,AAAA",
      signature_confirmed: "1"
    }

    assert_redirected_to patient_prescription_url(@patient, @prescription)
    @prescription.reload
    assert_equal "signed", @prescription.status
  end
end
