module Api
  module V1
    class PlatformAccountsController < BaseController
      before_action :require_system_admin!
      before_action :set_account, only: :update

      def create
        clinic, owner = ClinicOnboarding.create!(
          clinic_params: platform_account_params.fetch(:clinic),
          owner_params: platform_account_params.fetch(:owner),
          account_params: platform_account_params.fetch(:account, {})
        )

        render json: {
          data: {
            account: AccountSerializer.call(clinic.account),
            clinic: ClinicSerializer.call(clinic),
            owner: UserSerializer.call(owner)
          }
        }, status: :created
      rescue ActiveRecord::RecordInvalid => error
        render_validation_errors(error.record)
      end

      def update
        if @account.update(account_update_params)
          render_resource(@account, serializer: AccountSerializer)
        else
          render_validation_errors(@account)
        end
      end

      private

      def require_system_admin!
        return if current_user&.system_admin?

        render_error("forbidden", "Only system admins can manage platform accounts.", status: :forbidden)
      end

      def set_account
        @account = Account.find(params[:id])
      end

      def platform_account_params
        params.require(:platform_account).permit(
          account: %i[name slug billing_email subscription_plan subscription_status subscription_starts_on subscription_ends_on trial_ends_on],
          clinic: %i[name slug contact_email phone subscription_plan time_zone currency_code],
          owner: %i[name email password]
        )
      end

      def account_update_params
        params.require(:account).permit(
          :name,
          :slug,
          :billing_email,
          :subscription_plan,
          :subscription_status,
          :subscription_starts_on,
          :subscription_ends_on,
          :trial_ends_on
        )
      end
    end
  end
end
