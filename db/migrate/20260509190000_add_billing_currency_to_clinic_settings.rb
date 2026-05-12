class AddBillingCurrencyToClinicSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :clinic_settings, :currency_code, :string, null: false, default: "USD"
    add_column :clinic_settings, :currency_locale, :string, null: false, default: "en-US"
  end
end
