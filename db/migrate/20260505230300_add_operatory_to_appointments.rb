class AddOperatoryToAppointments < ActiveRecord::Migration[8.0]
  def change
    add_column :appointments, :operatory, :string
    add_index :appointments, [:operatory, :starts_at]
  end
end
