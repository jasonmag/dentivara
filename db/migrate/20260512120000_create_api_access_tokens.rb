class CreateApiAccessTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :api_access_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :token_digest, null: false
      t.json :scopes, null: false, default: []
      t.datetime :expires_at
      t.datetime :revoked_at
      t.datetime :last_used_at
      t.string :last_used_ip
      t.string :last_used_user_agent

      t.timestamps
    end

    add_index :api_access_tokens, :token_digest, unique: true
    add_index :api_access_tokens, [ :user_id, :revoked_at ]
    add_index :api_access_tokens, :expires_at
  end
end
