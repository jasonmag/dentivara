class AllowAccountOnlyUsers < ActiveRecord::Migration[8.0]
  def change
    change_column_null :users, :clinic_id, true
  end
end
