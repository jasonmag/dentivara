class CreateIntraoralScans < ActiveRecord::Migration[8.0]
  def change
    create_table :intraoral_scans do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.date :captured_on, null: false
      t.string :scan_type, null: false, default: "intraoral_scan"
      t.text :notes

      t.timestamps
    end

    add_index :intraoral_scans, [ :patient_id, :captured_on ]
  end
end
