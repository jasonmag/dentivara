class CreateAccountSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :account_subscriptions do |t|
      t.references :account, null: false, foreign_key: true
      t.string :subscription_plan, null: false
      t.string :subscription_status, null: false
      t.date :subscription_starts_on
      t.date :subscription_ends_on

      t.timestamps
    end

    add_index :account_subscriptions, :subscription_plan
    add_index :account_subscriptions, :subscription_status
    add_index :account_subscriptions, :subscription_starts_on
    add_index :account_subscriptions, :subscription_ends_on

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          INSERT INTO account_subscriptions
            (account_id, subscription_plan, subscription_status, subscription_starts_on, subscription_ends_on, created_at, updated_at)
          SELECT
            id, subscription_plan, subscription_status, subscription_starts_on, subscription_ends_on, created_at, updated_at
          FROM accounts
        SQL
      end
    end
  end
end
