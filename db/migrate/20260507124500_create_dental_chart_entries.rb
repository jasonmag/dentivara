class CreateDentalChartEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :dental_chart_entries do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :tooth_code
      t.string :entry_type, null: false
      t.text :notes, null: false
      t.date :recorded_on, null: false

      t.timestamps
    end

    add_index :dental_chart_entries, [:patient_id, :recorded_on]
    add_index :dental_chart_entries, :entry_type
  end
end
