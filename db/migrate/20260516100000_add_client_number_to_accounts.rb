require "securerandom"

class AddClientNumberToAccounts < ActiveRecord::Migration[8.0]
  def up
    add_column :accounts, :client_number, :string

    Account.reset_column_information
    Account.find_each do |account|
      account.update_columns(client_number: next_client_number)
    end

    change_column_null :accounts, :client_number, false
    add_index :accounts, :client_number, unique: true
  end

  def down
    remove_index :accounts, :client_number
    remove_column :accounts, :client_number
  end

  private

  def next_client_number
    loop do
      value = "CL-#{SecureRandom.alphanumeric(8).upcase}"
      return value unless Account.exists?(client_number: value)
    end
  end
end
