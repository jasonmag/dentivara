class AddSubscriptionWindowToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :subscription_starts_on, :date
    add_column :accounts, :subscription_ends_on, :date
    add_index :accounts, :subscription_starts_on
    add_index :accounts, :subscription_ends_on

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE accounts
          SET subscription_starts_on = DATE(created_at),
              subscription_ends_on = trial_ends_on
          WHERE subscription_starts_on IS NULL
        SQL
      end
    end
  end
end
