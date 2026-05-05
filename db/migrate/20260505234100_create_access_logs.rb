class CreateAccessLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :access_logs do |t|
      t.references :user, foreign_key: true
      t.string :resource_type, null: false
      t.bigint :resource_id, null: false
      t.string :action, null: false
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end

    add_index :access_logs, [:resource_type, :resource_id, :created_at], name: "idx_access_logs_resource"
    add_index :access_logs, :action
  end
end
