class AddColorToClinicServices < ActiveRecord::Migration[8.0]
  def change
    add_column :clinic_services, :color, :string, default: "#2a9d8f", null: false
  end
end
