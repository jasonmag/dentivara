class CreatePrescriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :prescriptions do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :document_template, foreign_key: true
      t.references :drafted_by_user, null: false, foreign_key: { to_table: :users }
      t.references :signed_by_user, foreign_key: { to_table: :users }
      t.string :status, null: false, default: "draft"
      t.date :issued_on, null: false
      t.datetime :signed_at
      t.text :body, null: false
      t.text :signature_snapshot

      t.timestamps
    end

    add_index :prescriptions, [:patient_id, :issued_on]
    add_index :prescriptions, :status
  end
end
