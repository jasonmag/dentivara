module Api
  module V1
    class SubscriptionPlanSerializer
      def self.call(plan)
        {
          id: plan.id,
          name: plan.name,
          code: plan.code,
          price_per_month: plan.price_per_month,
          clinics_included: plan.clinics_included,
          extra_clinic_price: plan.extra_clinic_price,
          currency_code: ClinicSetting.current_currency_code,
          active: plan.active,
          position: plan.position,
          created_at: plan.created_at,
          updated_at: plan.updated_at
        }
      end
    end
  end
end
