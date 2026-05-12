class CreatePatientConsents < ActiveRecord::Migration[8.0]
  def change
    create_table :patient_consents do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :document_version, null: false
      t.string :consent_type, null: false
      t.datetime :consented_at, null: false
      t.json :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :patient_consents, [:patient_id, :consent_type, :consented_at], name: "idx_patient_consents_lookup"
  end
end
