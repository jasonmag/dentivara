class AddQueueEtaSettingsToClinicSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :clinic_settings, :queue_eta_minutes_default, :integer, null: false, default: 20
    add_column :clinic_settings, :queue_eta_minutes_scheduled, :integer, null: false, default: 20
    add_column :clinic_settings, :queue_eta_minutes_walk_in, :integer, null: false, default: 25
    add_column :clinic_settings, :queue_eta_minutes_emergency, :integer, null: false, default: 10
    add_column :clinic_settings, :queue_eta_minutes_priority, :integer, null: false, default: 15
  end
end
