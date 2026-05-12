class AddUserReferenceToPatients < ActiveRecord::Migration[8.0]
  def change
    return if column_exists?(:patients, :user_id)

    add_reference :patients, :user, foreign_key: true, index: { unique: true }
  end
end
