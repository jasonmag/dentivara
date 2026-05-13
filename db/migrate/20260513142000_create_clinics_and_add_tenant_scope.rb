class CreateClinicsAndAddTenantScope < ActiveRecord::Migration[8.0]
  TENANT_TABLES = %i[
    users patients appointments treatment_records invoices payments clinic_services
    clinic_settings audit_logs notifications access_logs
  ].freeze

  def change
    create_table :clinics do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :contact_email
      t.string :phone
      t.string :subscription_plan, default: "starter", null: false
      t.string :subscription_status, default: "trialing", null: false
      t.date :trial_ends_on
      t.datetime :suspended_at
      t.json :plan_limits, default: {}, null: false
      t.json :feature_flags, default: {}, null: false

      t.timestamps
    end

    add_index :clinics, :slug, unique: true
    add_index :clinics, :subscription_status
    add_index :clinics, :subscription_plan

    reversible do |dir|
      dir.up do
        default_clinic_id = create_default_clinic

        TENANT_TABLES.each do |table_name|
          add_reference table_name, :clinic, foreign_key: true
          execute "UPDATE #{table_name} SET clinic_id = #{default_clinic_id}"
          change_column_null table_name, :clinic_id, false
        end

        remove_index :clinic_services, :name
        add_index :clinic_services, [ :clinic_id, :name ], unique: true
        remove_index :clinic_settings, :clinic_id
        add_index :clinic_settings, :clinic_id, unique: true
      end

      dir.down do
        remove_index :clinic_settings, :clinic_id
        remove_index :clinic_services, [ :clinic_id, :name ]
        add_index :clinic_services, :name, unique: true

        TENANT_TABLES.reverse_each do |table_name|
          remove_reference table_name, :clinic, foreign_key: true
        end
      end
    end
  end

  private

  def create_default_clinic
    now = Time.current
    insert <<~SQL.squish
      INSERT INTO clinics
        (name, slug, contact_email, subscription_plan, subscription_status, trial_ends_on, plan_limits, feature_flags, created_at, updated_at)
      VALUES
        ('Dentivara Demo Clinic', 'dentivara-demo', 'owner@dentivara.local', 'clinic', 'active', '#{30.days.from_now.to_date}', '{}', '{}', '#{now.to_fs(:db)}', '#{now.to_fs(:db)}')
    SQL

    select_value("SELECT id FROM clinics WHERE slug = 'dentivara-demo'")
  end
end
