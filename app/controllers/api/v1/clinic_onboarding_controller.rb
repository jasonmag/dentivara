module Api
  module V1
    class ClinicOnboardingController < BaseController
      skip_before_action :authenticate_api!, only: :create
      skip_after_action :record_api_token_usage, only: :create

      def create
        clinic, owner = ClinicOnboarding.create!(
          clinic_params: onboarding_params.fetch(:clinic),
          owner_params: onboarding_params.fetch(:owner)
        )

        access_token, raw_token = ApiAccessToken.generate!(
          user: owner,
          name: "Dentivara Web",
          expires_at: 30.days.from_now
        )

        render json: {
          data: {
            clinic: ClinicSerializer.call(clinic),
            user: UserSerializer.call(owner),
            token: raw_token,
            token_type: "Bearer",
            expires_at: access_token.expires_at
          }
        }, status: :created
      rescue ActiveRecord::RecordInvalid => error
        render_validation_errors(error.record)
      end

      private

      def onboarding_params
        params.require(:onboarding).permit(
          clinic: %i[name slug contact_email phone subscription_plan time_zone currency_code],
          owner: %i[name email password]
        )
      end
    end
  end
end
