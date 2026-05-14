module Api
  module V1
    class ImpersonationsController < BaseController
      before_action :require_system_admin!

      def create
        target = User.clinic_owner.find(impersonation_params[:user_id])
        clinic = target.accessible_clinics.find_by(id: impersonation_params[:clinic_id].presence || target.clinic_id)
        return render_error("forbidden", "The target owner cannot access that clinic.", status: :forbidden) if clinic.blank?

        access_token, raw_token = ApiAccessToken.generate!(
          user: target,
          name: "System admin impersonation",
          scopes: %w[impersonation],
          expires_at: 2.hours.from_now,
          impersonated_by_user: current_user,
          impersonation_reason: impersonation_params[:reason].presence
        )

        render json: {
          data: {
            token: raw_token,
            token_type: "Bearer",
            expires_at: access_token.expires_at,
            user: UserSerializer.call(target),
            clinic: ClinicSerializer.call(clinic),
            impersonated_by: UserSerializer.call(current_user)
          }
        }, status: :created
      end

      private

      def require_system_admin!
        return if current_user&.system_admin?

        render_error("forbidden", "Only system admins can impersonate clinic owners.", status: :forbidden)
      end

      def impersonation_params
        params.require(:impersonation).permit(:user_id, :clinic_id, :reason)
      end
    end
  end
end
