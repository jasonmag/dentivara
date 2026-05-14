class AddSaasAccountsAndPatientSelfService < ActiveRecord::Migration[8.0]
  def up
    create_table :accounts do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :billing_email
      t.string :subscription_plan, default: "starter", null: false
      t.string :subscription_status, default: "trialing", null: false
      t.date :trial_ends_on
      t.datetime :suspended_at
      t.json :plan_limits, default: {}, null: false
      t.json :feature_flags, default: {}, null: false

      t.timestamps
    end
    add_index :accounts, :slug, unique: true
    add_index :accounts, :subscription_status
    add_index :accounts, :subscription_plan

    create_table :account_memberships do |t|
      t.references :account, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, null: false
      t.datetime :accepted_at

      t.timestamps
    end
    add_index :account_memberships, [ :account_id, :user_id ], unique: true
    add_index :account_memberships, :role

    add_reference :clinics, :account, foreign_key: true

    say_with_time "Backfilling SaaS accounts from clinics" do
      now = quoted_timestamp
      select_all("SELECT * FROM clinics").each do |clinic|
        account_slug = unique_account_slug(clinic["slug"])
        execute <<~SQL.squish
          INSERT INTO accounts
            (name, slug, billing_email, subscription_plan, subscription_status, trial_ends_on, suspended_at, plan_limits, feature_flags, created_at, updated_at)
          VALUES
            (#{quote(clinic["name"])}, #{quote(account_slug)}, #{quote(clinic["contact_email"])},
             #{quote(clinic["subscription_plan"])}, #{quote(clinic["subscription_status"])},
             #{quote(clinic["trial_ends_on"].presence)}, #{quote(clinic["suspended_at"].presence)},
             #{quote(clinic["plan_limits"] || "{}")}, #{quote(clinic["feature_flags"] || "{}")},
             #{now}, #{now})
        SQL
        account_id = select_value("SELECT id FROM accounts WHERE slug = #{quote(account_slug)}")
        execute "UPDATE clinics SET account_id = #{account_id} WHERE id = #{clinic["id"]}"
      end
    end

    change_column_null :clinics, :account_id, false

    say_with_time "Backfilling account memberships from clinic owners" do
      execute <<~SQL.squish
        INSERT INTO account_memberships (account_id, user_id, role, accepted_at, created_at, updated_at)
        SELECT DISTINCT clinics.account_id, users.id, 'owner', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        FROM users
        INNER JOIN clinics ON clinics.id = users.clinic_id
        WHERE users.role IN (0, 5)
      SQL

      execute <<~SQL.squish
        INSERT INTO account_memberships (account_id, user_id, role, accepted_at, created_at, updated_at)
        SELECT DISTINCT clinics.account_id, users.id, 'member', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        FROM users
        INNER JOIN clinics ON clinics.id = users.clinic_id
        WHERE users.role NOT IN (0, 5)
          AND NOT EXISTS (
            SELECT 1 FROM account_memberships
            WHERE account_memberships.account_id = clinics.account_id
              AND account_memberships.user_id = users.id
          )
      SQL
    end

    add_column :patients, :claim_code, :string
    add_column :patients, :claimed_at, :datetime
    add_index :patients, :claim_code, unique: true

    create_table :patient_links do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :clinic, null: false, foreign_key: true
      t.datetime :claimed_at, null: false

      t.timestamps
    end
    add_index :patient_links, [ :patient_id, :user_id ], unique: true
    add_index :patient_links, [ :clinic_id, :user_id ]

    say_with_time "Backfilling patient claim codes and links" do
      select_values("SELECT id FROM patients WHERE claim_code IS NULL").each do |patient_id|
        execute "UPDATE patients SET claim_code = #{quote(unique_claim_code)} WHERE id = #{patient_id}"
      end

      execute <<~SQL.squish
        INSERT INTO patient_links (patient_id, user_id, clinic_id, claimed_at, created_at, updated_at)
        SELECT id, user_id, clinic_id, COALESCE(claimed_at, CURRENT_TIMESTAMP), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        FROM patients
        WHERE user_id IS NOT NULL
      SQL
    end

    change_column_null :patients, :claim_code, false
  end

  def down
    drop_table :patient_links
    remove_index :patients, :claim_code
    remove_column :patients, :claimed_at
    remove_column :patients, :claim_code

    remove_reference :clinics, :account, foreign_key: true
    drop_table :account_memberships
    drop_table :accounts
  end

  private

  def unique_account_slug(base)
    slug = base.presence || "account"
    candidate = slug
    suffix = 2

    while select_value("SELECT 1 FROM accounts WHERE slug = #{quote(candidate)} LIMIT 1").present?
      candidate = "#{slug}-#{suffix}"
      suffix += 1
    end

    candidate
  end

  def unique_claim_code
    loop do
      code = "PT-#{SecureRandom.alphanumeric(10).upcase}"
      return code if select_value("SELECT 1 FROM patients WHERE claim_code = #{quote(code)} LIMIT 1").blank?
    end
  end

  def quoted_timestamp
    quote(Time.current.to_fs(:db))
  end
end
