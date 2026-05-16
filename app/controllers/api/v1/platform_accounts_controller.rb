module Api
  module V1
    class PlatformAccountsController < BaseController
      before_action :require_system_admin!
      before_action :set_account, only: :update

      def create
        attributes = client_account_attributes
        return render_error("password_confirmation_mismatch", "Client password confirmation does not match.", status: :unprocessable_entity) unless passwords_match?

        account, owner = create_account_owner!(attributes)

        render json: {
          data: {
            account: AccountSerializer.call(account),
            clinic: nil,
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
        params.require(:platform_account).permit(:client_name, :client_email, :client_password, :client_password_confirmation)
      end

      def passwords_match?
        permitted = platform_account_params
        permitted[:client_password].to_s == permitted[:client_password_confirmation].to_s
      end

      def client_account_attributes
        permitted = platform_account_params
        client_name = permitted.fetch(:client_name).to_s.squish
        client_email = permitted.fetch(:client_email).to_s.downcase.strip
        client_password = permitted.fetch(:client_password).to_s

        {
          account: {
            name: client_name,
            billing_email: client_email,
            subscription_plan: "clinic",
            subscription_status: "active"
          },
          owner: {
            name: client_name,
            email: client_email,
            password: client_password
          }
        }
      end

      def create_account_owner!(attributes)
        Account.transaction do
          account = Account.create!(attributes.fetch(:account))
          owner_attributes = attributes.fetch(:owner)
          owner = User.create!(
            account_only: true,
            name: owner_attributes.fetch(:name),
            email: owner_attributes.fetch(:email),
            password: owner_attributes.fetch(:password),
            password_confirmation: owner_attributes.fetch(:password),
            role: :clinic_owner
          )
          owner.account_memberships.create!(
            account: account,
            role: "owner",
            accepted_at: Time.current
          )
          [account, owner]
        end
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
