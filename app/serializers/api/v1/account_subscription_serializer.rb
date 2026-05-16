module Api
  module V1
    class AccountSubscriptionSerializer
      def self.call(subscription)
        {
          id: subscription.id,
          subscription_plan: subscription.subscription_plan,
          subscription_status: subscription.subscription_status,
          subscription_starts_on: subscription.subscription_starts_on,
          subscription_ends_on: subscription.subscription_ends_on,
          created_at: subscription.created_at,
          updated_at: subscription.updated_at
        }
      end
    end
  end
end
