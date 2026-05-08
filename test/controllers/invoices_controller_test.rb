require "test_helper"

class InvoicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @invoice = invoices(:one)
    sign_in_as(users(:one))
  end

  test "should get index" do
    get invoices_url
    assert_response :success
  end

  test "should get new" do
    get new_invoice_url
    assert_response :success
  end

  test "should create invoice" do
    treatment_record = TreatmentRecord.create!(
      appointment: appointments(:two),
      clinical_notes: "Test billing record.",
      cost: 500,
      patient: patients(:two),
      performed_on: Date.current,
      service_type: "Test Billing",
      user: users(:two)
    )

    assert_difference("Invoice.count") do
      post invoices_url, params: { invoice: { approved_by_admin_at: @invoice.approved_by_admin_at, approved_by_dentist_at: @invoice.approved_by_dentist_at, balance_amount: 500, issued_on: @invoice.issued_on, patient_id: patients(:two).id, status: "approved", total_amount: 500, treatment_record_id: treatment_record.id } }
    end

    assert_redirected_to invoice_url(Invoice.last)
  end

  test "should show invoice" do
    get invoice_url(@invoice)
    assert_response :success
  end

  test "should get edit" do
    get edit_invoice_url(@invoice)
    assert_response :success
  end

  test "should update invoice" do
    patch invoice_url(@invoice), params: { invoice: { approved_by_admin_at: @invoice.approved_by_admin_at, approved_by_dentist_at: @invoice.approved_by_dentist_at, balance_amount: @invoice.balance_amount, issued_on: @invoice.issued_on, patient_id: @invoice.patient_id, status: @invoice.status, total_amount: @invoice.total_amount, treatment_record_id: @invoice.treatment_record_id } }
    assert_redirected_to invoice_url(@invoice)
  end

  test "should destroy invoice" do
    assert_difference("Invoice.count", -1) do
      delete invoice_url(@invoice)
    end

    assert_redirected_to invoices_url
  end
  end
