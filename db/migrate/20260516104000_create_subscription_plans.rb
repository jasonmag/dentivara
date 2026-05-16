class CreateSubscriptionPlans < ActiveRecord::Migration[8.0]
  DEFAULT_PLANS = [
    [ "Founding Clinic", "founding_clinic", "PHP 990", "2", "PHP 500/month", 1 ],
    [ "Starter", "starter", "PHP 1,490", "1", "PHP 700/month", 2 ],
    [ "Growing", "growing", "PHP 2,990", "3", "PHP 700/month", 3 ],
    [ "Enterprise", "enterprise", "Custom", "Custom", "Custom", 4 ]
  ].freeze

  def change
    create_table :subscription_plans do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.string :price_per_month, null: false
      t.string :clinics_included, null: false
      t.string :extra_clinic_price, null: false
      t.boolean :active, default: true, null: false
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :subscription_plans, :code, unique: true
    add_index :subscription_plans, :active
    add_index :subscription_plans, :position

    reversible do |dir|
      dir.up do
        now = quote(Time.current)
        DEFAULT_PLANS.each do |name, code, price, clinics, extra_clinic, position|
          execute <<~SQL.squish
            INSERT INTO subscription_plans
              (name, code, price_per_month, clinics_included, extra_clinic_price, active, position, created_at, updated_at)
            VALUES
              (#{quote(name)}, #{quote(code)}, #{quote(price)}, #{quote(clinics)}, #{quote(extra_clinic)}, 1, #{position}, #{now}, #{now})
          SQL
        end
      end
    end
  end
end
