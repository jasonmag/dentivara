class ConvertSubscriptionPlanValuesToNumbers < ActiveRecord::Migration[8.0]
  class MigrationSubscriptionPlan < ActiveRecord::Base
    self.table_name = "subscription_plans"
  end

  def up
    add_column :subscription_plans, :price_per_month_amount, :integer
    add_column :subscription_plans, :clinics_included_count, :integer
    add_column :subscription_plans, :extra_clinic_price_amount, :integer

    MigrationSubscriptionPlan.reset_column_information
    MigrationSubscriptionPlan.find_each do |plan|
      plan.update_columns(
        price_per_month_amount: numeric_value(plan.price_per_month),
        clinics_included_count: numeric_value(plan.clinics_included),
        extra_clinic_price_amount: numeric_value(plan.extra_clinic_price)
      )
    end

    remove_column :subscription_plans, :price_per_month
    remove_column :subscription_plans, :clinics_included
    remove_column :subscription_plans, :extra_clinic_price

    rename_column :subscription_plans, :price_per_month_amount, :price_per_month
    rename_column :subscription_plans, :clinics_included_count, :clinics_included
    rename_column :subscription_plans, :extra_clinic_price_amount, :extra_clinic_price
  end

  def down
    add_column :subscription_plans, :price_per_month_text, :string
    add_column :subscription_plans, :clinics_included_text, :string
    add_column :subscription_plans, :extra_clinic_price_text, :string

    MigrationSubscriptionPlan.reset_column_information
    MigrationSubscriptionPlan.find_each do |plan|
      plan.update_columns(
        price_per_month_text: text_value(plan.price_per_month),
        clinics_included_text: text_value(plan.clinics_included),
        extra_clinic_price_text: text_value(plan.extra_clinic_price)
      )
    end

    remove_column :subscription_plans, :price_per_month
    remove_column :subscription_plans, :clinics_included
    remove_column :subscription_plans, :extra_clinic_price

    rename_column :subscription_plans, :price_per_month_text, :price_per_month
    rename_column :subscription_plans, :clinics_included_text, :clinics_included
    rename_column :subscription_plans, :extra_clinic_price_text, :extra_clinic_price

    change_column_null :subscription_plans, :price_per_month, false
    change_column_null :subscription_plans, :clinics_included, false
    change_column_null :subscription_plans, :extra_clinic_price, false
  end

  private

  def numeric_value(value)
    digits = value.to_s.gsub(/[^\d]/, "")
    digits.presence&.to_i
  end

  def text_value(value)
    value.nil? ? "Custom" : value.to_s
  end
end
