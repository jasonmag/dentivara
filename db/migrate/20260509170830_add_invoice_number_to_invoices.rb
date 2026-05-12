class AddInvoiceNumberToInvoices < ActiveRecord::Migration[8.0]
  def up
    add_column :invoices, :invoice_number, :string
    add_index :invoices, :invoice_number, unique: true
    remove_index :invoices, :treatment_record_id
    add_index :invoices, :treatment_record_id, unique: true

    Invoice.reset_column_information
    Invoice.find_each do |invoice|
      next if invoice.invoice_number.present?

      year = invoice.issued_on&.year || Time.zone.today.year
      invoice.update_columns(invoice_number: format("INV-%<year>d-%<id>05d", year: year, id: invoice.id))
    end
  end

  def down
    remove_index :invoices, :treatment_record_id
    remove_index :invoices, :invoice_number
    remove_column :invoices, :invoice_number
  end
end
