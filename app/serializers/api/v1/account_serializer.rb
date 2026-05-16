module Api
  module V1
    class AccountSerializer
      def self.call(account)
        {
          id: account.id,
          client_number: account.client_number,
          name: account.name,
          slug: account.slug,
          billing_email: account.billing_email,
          subscription_plan: account.subscription_plan,
          subscription_status: account.subscription_status,
          subscription_starts_on: account.subscription_starts_on,
          subscription_ends_on: account.subscription_ends_on,
          trial_ends_on: account.trial_ends_on,
          suspended_at: account.suspended_at,
          plan_limits: account.plan_limits,
          feature_flags: account.feature_flags,
          subscriptions: account.account_subscriptions.recent_first.map { |subscription| AccountSubscriptionSerializer.call(subscription) },
          created_at: account.created_at,
          updated_at: account.updated_at
        }
      end
    end
  end
end
