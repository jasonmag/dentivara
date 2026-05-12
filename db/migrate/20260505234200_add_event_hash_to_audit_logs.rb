class AddEventHashToAuditLogs < ActiveRecord::Migration[8.0]
  def change
    add_column :audit_logs, :event_hash, :string
    add_column :audit_logs, :previous_hash, :string
    add_index :audit_logs, :event_hash
  end
end
