class EnhancePaymentsForHistoryAndProofs < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :notes, :text
    add_column :payments, :recorded_by_user_id, :integer

    add_index :payments, :recorded_by_user_id
    add_index :payments, [ :invoice_id, :amount, :paid_on, :method, :reference_code ], unique: true, name: "index_payments_on_dedup_fields"
  end
end
