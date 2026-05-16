class UpdateSubscriptionPlans < ActiveRecord::Migration[8.0]
  def up
    update_plan_values("clinic", "starter")
    update_plan_values("pro", "growing")
  end

  def down
    update_plan_values("growing", "pro")
  end

  private

  def update_plan_values(from, to)
    execute <<~SQL.squish
      UPDATE accounts
      SET subscription_plan = #{quote(to)}
      WHERE subscription_plan = #{quote(from)}
    SQL

    execute <<~SQL.squish
      UPDATE clinics
      SET subscription_plan = #{quote(to)}
      WHERE subscription_plan = #{quote(from)}
    SQL
  end
end
