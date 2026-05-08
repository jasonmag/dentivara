class AddSchedulingSupport < ActiveRecord::Migration[8.0]
  def change
    create_table :clinic_schedules do |t|
      t.integer :day_of_week, null: false
      t.time :opens_at
      t.time :closes_at
      t.boolean :closed, default: false, null: false
      t.boolean :emergency_only, default: false, null: false
      t.integer :max_concurrent_appointments, default: 2, null: false

      t.timestamps
    end

    add_index :clinic_schedules, :day_of_week, unique: true

    create_table :clinic_closures do |t|
      t.date :date, null: false
      t.string :reason
      t.boolean :emergency_only, default: false, null: false

      t.timestamps
    end

    add_index :clinic_closures, :date, unique: true

    create_table :dentist_schedules do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :day_of_week, null: false
      t.time :starts_at, null: false
      t.time :ends_at, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :dentist_schedules, [ :user_id, :day_of_week ]

    create_table :dentist_schedule_overrides do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date, null: false
      t.time :available_from
      t.time :available_until
      t.boolean :unavailable, default: false, null: false
      t.string :reason

      t.timestamps
    end

    add_index :dentist_schedule_overrides, [ :user_id, :date ], unique: true

    change_table :appointments, bulk: true do |t|
      t.references :clinic_service, foreign_key: true
      t.integer :duration_minutes
      t.integer :buffer_minutes, default: 10, null: false
      t.integer :preferred_user_id
      t.string :time_preference
      t.string :cancellation_reason
      t.datetime :cancelled_at
      t.integer :rescheduled_from_appointment_id
    end

    add_foreign_key :appointments, :users, column: :preferred_user_id
    add_foreign_key :appointments, :appointments, column: :rescheduled_from_appointment_id
    add_index :appointments, :preferred_user_id
    add_index :appointments, :rescheduled_from_appointment_id
    add_index :appointments, :cancelled_at
  end
end
