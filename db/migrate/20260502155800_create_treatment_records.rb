class CreateTreatmentRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :treatment_records do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :appointment, null: false, foreign_key: true
      t.string :service_type
      t.text :clinical_notes
      t.decimal :cost
      t.date :performed_on

      t.timestamps
    end
  end
end
