class CompleteTenantScope < ActiveRecord::Migration[8.0]
  TENANT_TABLES = %i[
    clinic_schedules clinic_closures dentist_schedules dentist_schedule_overrides
    dental_chart_entries document_templates intake_form_submissions intraoral_scans
    patient_consents prescriptions queue_entries role_permissions
  ].freeze

  def change
    create_table :clinic_memberships do |t|
      t.references :clinic, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, null: false
      t.datetime :accepted_at

      t.timestamps
    end

    add_index :clinic_memberships, [ :clinic_id, :user_id ], unique: true
    add_index :clinic_memberships, :role

    reversible do |dir|
      dir.up do
        default_clinic_id = default_clinic_id!

        TENANT_TABLES.each do |table_name|
          add_reference table_name, :clinic, foreign_key: true
          execute "UPDATE #{table_name} SET clinic_id = #{default_clinic_id}"
          change_column_null table_name, :clinic_id, false
        end

        migrate_unique_indexes_up
        backfill_memberships
      end

      dir.down do
        migrate_unique_indexes_down

        TENANT_TABLES.reverse_each do |table_name|
          remove_reference table_name, :clinic, foreign_key: true
        end
      end
    end
  end

  private

  def default_clinic_id!
    select_value("SELECT id FROM clinics ORDER BY id LIMIT 1")
  end

  def migrate_unique_indexes_up
    remove_index :clinic_schedules, :day_of_week
    add_index :clinic_schedules, [ :clinic_id, :day_of_week ], unique: true

    remove_index :clinic_closures, :date
    add_index :clinic_closures, [ :clinic_id, :date ], unique: true

    remove_index :dentist_schedule_overrides, [ :user_id, :date ]
    add_index :dentist_schedule_overrides, [ :clinic_id, :user_id, :date ], unique: true, name: "idx_dentist_overrides_clinic_user_date"

    remove_index :role_permissions, :role
    add_index :role_permissions, [ :clinic_id, :role ], unique: true
  end

  def migrate_unique_indexes_down
    remove_index :clinic_schedules, [ :clinic_id, :day_of_week ]
    add_index :clinic_schedules, :day_of_week, unique: true

    remove_index :clinic_closures, [ :clinic_id, :date ]
    add_index :clinic_closures, :date, unique: true

    remove_index :dentist_schedule_overrides, name: "idx_dentist_overrides_clinic_user_date"
    add_index :dentist_schedule_overrides, [ :user_id, :date ], unique: true

    remove_index :role_permissions, [ :clinic_id, :role ]
    add_index :role_permissions, :role, unique: true
  end

  def backfill_memberships
    execute <<~SQL.squish
      INSERT INTO clinic_memberships (clinic_id, user_id, role, accepted_at, created_at, updated_at)
      SELECT clinic_id, id, role, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM users
    SQL
  end
end
