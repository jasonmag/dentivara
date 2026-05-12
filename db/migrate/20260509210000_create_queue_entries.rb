class CreateQueueEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :queue_entries do |t|
      t.references :appointment, null: true, foreign_key: true
      t.references :patient, null: false, foreign_key: true
      t.string :queue_type, null: false, default: "scheduled"
      t.integer :priority_level, null: false, default: 0
      t.string :status, null: false, default: "waiting"
      t.datetime :arrived_at
      t.datetime :called_at
      t.datetime :served_at
      t.integer :position, null: false, default: 0
      t.text :notes

      t.timestamps
    end

    add_index :queue_entries, [ :status, :priority_level, :arrived_at ], name: "idx_queue_entries_dispatch_order"
    add_index :queue_entries, [ :appointment_id, :status ], unique: true, where: "status IN ('waiting','called')", name: "idx_queue_entries_active_appointment"
  end
end
