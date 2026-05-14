class AddImpersonationToApiAccessTokens < ActiveRecord::Migration[8.0]
  def change
    add_reference :api_access_tokens, :impersonated_by_user, foreign_key: { to_table: :users }
    add_column :api_access_tokens, :impersonation_reason, :string
  end
end
