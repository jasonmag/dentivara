class CreateClinicSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :clinic_settings do |t|
      t.string :time_zone, default: "Asia/Manila", null: false

      t.timestamps
    end
  end
end
