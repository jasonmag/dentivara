module Api
  module V1
    class ClinicSerializer
      def self.call(clinic)
        {
          id: clinic.id,
          account_id: clinic.account_id,
          name: clinic.name,
          slug: clinic.slug,
          contact_email: clinic.contact_email,
          phone: clinic.phone,
          subscription_plan: clinic.subscription_plan,
          subscription_status: clinic.subscription_status,
          trial_ends_on: clinic.trial_ends_on,
          suspended_at: clinic.suspended_at,
          archived_at: clinic.archived_at,
          plan_limits: clinic.plan_limits,
          feature_flags: clinic.feature_flags,
          created_at: clinic.created_at,
          updated_at: clinic.updated_at
        }
      end
    end
  end
end
