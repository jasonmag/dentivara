class AddAvailabilityIndexesAndSourceToNotifications < ActiveRecord::Migration[8.0]
  def change
    add_index :appointments, [:user_id, :starts_at]
    add_index :appointments, [:patient_id, :starts_at]
    add_column :notifications, :source_record_type, :string
    add_column :notifications, :source_record_id, :integer
    add_index :notifications, [:source_record_type, :source_record_id]
  end
end
