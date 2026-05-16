class UpdateClinicStatusesToActiveInactive < ActiveRecord::Migration[8.0]
  def up
    change_column_default :clinics, :subscription_status, from: "trialing", to: "active"

    execute <<~SQL.squish
      UPDATE clinics
      SET subscription_status = CASE
        WHEN subscription_status IN ('cancelled', 'suspended') THEN 'inactive'
        ELSE 'active'
      END
    SQL
  end

  def down
    change_column_default :clinics, :subscription_status, from: "active", to: "trialing"

    execute <<~SQL.squish
      UPDATE clinics
      SET subscription_status = CASE
        WHEN subscription_status = 'inactive' THEN 'suspended'
        ELSE 'active'
      END
    SQL
  end
end
