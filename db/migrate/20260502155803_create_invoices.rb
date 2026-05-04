class CreateInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :invoices do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :treatment_record, null: false, foreign_key: true
      t.string :status
      t.decimal :total_amount
      t.decimal :balance_amount
      t.date :issued_on
      t.datetime :approved_by_dentist_at
      t.datetime :approved_by_admin_at

      t.timestamps
    end
  end
end
