module Api
  module V1
    class UserSerializer
      def self.call(user)
        subscription_account = subscription_account_for(user)

        {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
          clinic_id: user.clinic_id,
          account_subscription_status: subscription_account&.subscription_status,
          account_subscription_plan: subscription_account&.subscription_plan,
          account_subscription_starts_on: subscription_account&.subscription_starts_on,
          account_subscription_ends_on: subscription_account&.subscription_ends_on,
          account_subscription_expired: subscription_expired?(subscription_account),
          account_clinics_count: subscription_account&.clinics&.count,
          account_clinics_included: subscription_clinics_included(subscription_account),
          account_can_add_clinic: subscription_account&.subscription_allows_clinic_addition? || false,
          clinic: user.clinic.present? ? ClinicSerializer.call(user.clinic) : nil,
          accounts: user.accessible_accounts.map { |account| AccountSerializer.call(account) },
          clinics: user.accessible_clinics.map { |clinic| ClinicSerializer.call(clinic) },
          permissions: user.permission_matrix,
          created_at: user.created_at,
          updated_at: user.updated_at
        }
      end

      def self.subscription_account_for(user)
        return nil unless user.clinic_owner?

        user.accessible_accounts.order(:id).first || user.clinic&.account
      end

      def self.subscription_expired?(account)
        account&.subscription_ends_on.present? && account.subscription_ends_on < Date.current
      end

      def self.subscription_clinics_included(account)
        return nil if account.blank?

        SubscriptionPlan.find_by(code: account.subscription_plan)&.clinics_included
      end
    end
  end
end
