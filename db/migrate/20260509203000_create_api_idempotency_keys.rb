class CreateApiIdempotencyKeys < ActiveRecord::Migration[8.0]
  def change
    create_table :api_idempotency_keys do |t|
      t.string :key, null: false
      t.string :http_method, null: false
      t.string :path, null: false
      t.string :request_hash, null: false
      t.integer :response_code, null: false
      t.text :response_body, null: false
      t.datetime :expires_at

      t.timestamps
    end

    add_index :api_idempotency_keys, [ :key, :http_method, :path ], unique: true, name: "idx_api_idempotency_unique_scope"
    add_index :api_idempotency_keys, :expires_at
  end
end
