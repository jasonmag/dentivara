class CreatePatients < ActiveRecord::Migration[8.0]
  def change
    create_table :patients do |t|
      t.string :first_name
      t.string :last_name
      t.date :birth_date
      t.string :phone
      t.string :email
      t.string :emergency_contact_name
      t.string :emergency_contact_phone
      t.text :medical_history
      t.datetime :consented_at

      t.timestamps
    end
  end
end
