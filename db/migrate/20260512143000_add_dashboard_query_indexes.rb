class AddDashboardQueryIndexes < ActiveRecord::Migration[8.0]
  def change
    add_index :appointments, :starts_at
    add_index :invoices, :issued_on
    add_index :invoices, :updated_at
    add_index :patients, [ :last_name, :first_name ]
  end
end
