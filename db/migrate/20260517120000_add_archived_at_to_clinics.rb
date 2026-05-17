class AddArchivedAtToClinics < ActiveRecord::Migration[8.0]
  def change
    add_column :clinics, :archived_at, :datetime
    add_index :clinics, :archived_at
  end
end
