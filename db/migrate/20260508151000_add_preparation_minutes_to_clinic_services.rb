class AddPreparationMinutesToClinicServices < ActiveRecord::Migration[8.0]
  def change
    add_column :clinic_services, :preparation_minutes, :integer, default: 0, null: false
  end
end
