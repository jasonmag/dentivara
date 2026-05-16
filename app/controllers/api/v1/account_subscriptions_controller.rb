module Api
  module V1
    class AccountSubscriptionsController < BaseController
      before_action :require_clinic_owner!, only: %i[show create]
      before_action :require_system_admin!, only: :update
      before_action :set_account_subscription, only: :update

      def show
        render json: { data: payload_for(current_account) }
      end

      def create
        plan = SubscriptionPlan.find_by!(code: account_subscription_params.fetch(:subscription_plan), active: true)
        account = current_account

        Account.transaction do
          account.update!(
            subscription_plan: plan.code,
            subscription_status: "inactive",
            subscription_starts_on: Date.current,
            subscription_ends_on: 1.year.from_now.to_date
          )
          account.account_subscriptions.create!(
            subscription_plan: plan.code,
            subscription_status: "inactive",
            subscription_starts_on: account.subscription_starts_on,
            subscription_ends_on: account.subscription_ends_on
          )
        end

        render json: { data: payload_for(account.reload) }, status: :created
      rescue ActiveRecord::RecordInvalid => error
        render_validation_errors(error.record)
      end

      def update
        Account.transaction do
          @account_subscription.update!(account_subscription_status_params)
          @account_subscription.account.update!(
            subscription_plan: @account_subscription.subscription_plan,
            subscription_status: @account_subscription.subscription_status,
            subscription_starts_on: @account_subscription.subscription_starts_on,
            subscription_ends_on: @account_subscription.subscription_ends_on
          )
        end

        render_resource(@account_subscription.reload, serializer: AccountSubscriptionSerializer)
      rescue ActiveRecord::RecordInvalid => error
        render_validation_errors(error.record)
      end

      private

      def require_clinic_owner!
        return if current_user&.clinic_owner?

        render_error("forbidden", "Only clinic owners can manage their subscription request.", status: :forbidden)
      end

      def require_system_admin!
        return if current_user&.system_admin?

        render_error("forbidden", "Only system admins can update subscription status.", status: :forbidden)
      end

      def set_account_subscription
        @account_subscription = AccountSubscription.find(params[:id])
      end

      def current_account
        @current_account ||= current_user.accessible_accounts.order(:id).first || current_user.clinic&.account
        return @current_account if @current_account.present?

        raise ActiveRecord::RecordNotFound
      end

      def payload_for(account)
        {
          account: AccountSerializer.call(account),
          subscriptions: account.account_subscriptions.recent_first.map { |subscription| AccountSubscriptionSerializer.call(subscription) },
          plans: SubscriptionPlan.ordered.where(active: true).map { |plan| SubscriptionPlanSerializer.call(plan) }
        }
      end

      def account_subscription_params
        params.require(:account_subscription).permit(:subscription_plan)
      end

      def account_subscription_status_params
        params.require(:account_subscription).permit(:subscription_status)
      end
    end
  end
end
