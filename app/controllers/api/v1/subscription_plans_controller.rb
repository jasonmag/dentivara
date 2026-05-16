module Api
  module V1
    class SubscriptionPlansController < BaseController
      before_action :require_system_admin!
      before_action :set_subscription_plan, only: %i[show update destroy]

      def index
        render_collection(SubscriptionPlan.ordered, serializer: SubscriptionPlanSerializer)
      end

      def show
        render_resource(@subscription_plan, serializer: SubscriptionPlanSerializer)
      end

      def create
        subscription_plan = SubscriptionPlan.new(subscription_plan_params)

        if subscription_plan.save
          render_resource(subscription_plan, serializer: SubscriptionPlanSerializer, status: :created)
        else
          render_validation_errors(subscription_plan)
        end
      end

      def update
        if @subscription_plan.update(subscription_plan_params)
          render_resource(@subscription_plan, serializer: SubscriptionPlanSerializer)
        else
          render_validation_errors(@subscription_plan)
        end
      end

      def destroy
        @subscription_plan.destroy!
        head :no_content
      end

      private

      def require_system_admin!
        return if current_user&.system_admin?

        render_error("forbidden", "Only system admins can manage subscription plans.", status: :forbidden)
      end

      def set_subscription_plan
        @subscription_plan = SubscriptionPlan.find(params[:id])
      end

      def subscription_plan_params
        params.require(:subscription_plan).permit(:name, :code, :price_per_month, :clinics_included, :extra_clinic_price, :active, :position)
      end
    end
  end
end
