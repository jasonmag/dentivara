class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :invoice, null: false, foreign_key: true
      t.decimal :amount
      t.date :paid_on
      t.string :method
      t.string :reference_code

      t.timestamps
    end
  end
end
