class CreateRolePermissions < ActiveRecord::Migration[8.0]
  def change
    create_table :role_permissions do |t|
      t.integer :role, null: false
      t.json :permissions, null: false, default: {}

      t.timestamps
    end

    add_index :role_permissions, :role, unique: true
  end
end
