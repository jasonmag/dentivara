class CreateAppointments < ActiveRecord::Migration[8.0]
  def change
    create_table :appointments do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :source
      t.string :booking_type
      t.datetime :starts_at
      t.datetime :ends_at
      t.string :status
      t.text :notes

      t.timestamps
    end
  end
end
