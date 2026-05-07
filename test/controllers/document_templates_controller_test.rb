require "test_helper"

class DocumentTemplatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @patient = patients(:one)
    sign_in_as(@user)
  end

  test "destroy soft deletes template instead of deleting referenced prescription template" do
    template = DocumentTemplate.create!(
      name: "Referenced prescription template",
      kind: "prescription",
      body_template: "Medication: {{medication}}",
      active: true,
      default_for_prescription: true
    )
    Prescription.create!(
      patient: @patient,
      document_template: template,
      drafted_by_user: @user,
      issued_on: Date.current,
      body: "Amoxicillin 500mg"
    )

    assert_no_difference("DocumentTemplate.count") do
      delete document_template_url(template)
    end

    assert_redirected_to document_templates_url
    template.reload
    assert template.deleted?
    assert_not template.default_for_prescription?
  end

  test "deleted prescription templates are not offered for new prescriptions" do
    active_template = DocumentTemplate.create!(
      name: "Active prescription template",
      kind: "prescription",
      body_template: "Active body",
      active: true,
      default_for_prescription: true
    )
    deleted_template = DocumentTemplate.create!(
      name: "Deleted prescription template",
      kind: "prescription",
      body_template: "Deleted body",
      active: true,
      deleted_at: Time.current
    )

    get new_patient_prescription_url(@patient)

    assert_response :success
    assert_includes response.body, active_template.name
    assert_not_includes response.body, deleted_template.name
  end

  test "render template ignores deleted prescription templates" do
    deleted_template = DocumentTemplate.create!(
      name: "Deleted prescription template",
      kind: "prescription",
      body_template: "Deleted body",
      active: true,
      deleted_at: Time.current
    )

    get render_template_patient_prescriptions_url(@patient), params: { document_template_id: deleted_template.id }

    assert_response :success
    assert_equal({ "body" => "" }, JSON.parse(response.body))
  end
end
