class AddIndexesAndDefaults < ActiveRecord::Migration[8.0]
  def change
    change_column_default :users, :role, 2
    add_index :users, :email, unique: true
  end
end
