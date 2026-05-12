require "application_system_test_case"

class InvoicesTest < ApplicationSystemTestCase
  setup do
    @invoice = invoices(:one)
  end

  test "visiting the index" do
    visit invoices_url
    assert_selector "h1", text: "Invoices"
  end

  test "should create invoice" do
    visit invoices_url
    click_on "New invoice"

    fill_in "Approved by admin at", with: @invoice.approved_by_admin_at
    fill_in "Approved by dentist at", with: @invoice.approved_by_dentist_at
    fill_in "Balance amount", with: @invoice.balance_amount
    fill_in "Issued on", with: @invoice.issued_on
    fill_in "Patient", with: @invoice.patient_id
    fill_in "Status", with: @invoice.status
    fill_in "Total amount", with: @invoice.total_amount
    fill_in "Treatment record", with: @invoice.treatment_record_id
    click_on "Create Invoice"

    assert_text "Invoice was successfully created"
    click_on "Back"
  end

  test "should update Invoice" do
    visit invoice_url(@invoice)
    click_on "Edit this invoice", match: :first

    fill_in "Approved by admin at", with: @invoice.approved_by_admin_at.to_s
    fill_in "Approved by dentist at", with: @invoice.approved_by_dentist_at.to_s
    fill_in "Balance amount", with: @invoice.balance_amount
    fill_in "Issued on", with: @invoice.issued_on
    fill_in "Patient", with: @invoice.patient_id
    fill_in "Status", with: @invoice.status
    fill_in "Total amount", with: @invoice.total_amount
    fill_in "Treatment record", with: @invoice.treatment_record_id
    click_on "Update Invoice"

    assert_text "Invoice was successfully updated"
    click_on "Back"
  end

  test "should destroy Invoice" do
    visit invoice_url(@invoice)
    click_on "Destroy this invoice", match: :first

    assert_text "Invoice was successfully destroyed"
  end
end
