class CreateClinicServices < ActiveRecord::Migration[8.0]
  def change
    create_table :clinic_services do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :base_price, precision: 12, scale: 2, default: 0, null: false
      t.boolean :active, default: true, null: false
      t.integer :duration_minutes, default: 30, null: false

      t.timestamps
    end

    add_index :clinic_services, :name, unique: true
  end
end
