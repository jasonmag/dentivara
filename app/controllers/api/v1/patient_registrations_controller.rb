module Api
  module V1
    class PatientRegistrationsController < BaseController
      skip_before_action :authenticate_api!, only: :create
      skip_after_action :record_api_token_usage, only: :create

      def create
        user = User.new(patient_registration_params.merge(role: :patient))
        user.clinic = Clinic.default

        if user.save
          access_token, raw_token = ApiAccessToken.generate!(
            user: user,
            name: "Dentivara Patient Portal",
            expires_at: 30.days.from_now
          )

          render json: {
            data: {
              user: UserSerializer.call(user),
              token: raw_token,
              token_type: "Bearer",
              expires_at: access_token.expires_at
            }
          }, status: :created
        else
          render_validation_errors(user)
        end
      end

      private

      def patient_registration_params
        params.require(:patient_registration).permit(:name, :email, :password, :password_confirmation)
      end
    end
  end
end
