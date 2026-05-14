module Api
  module V1
    class SessionsController < BaseController
      skip_before_action :authenticate_api!, only: :create
      skip_after_action :record_api_token_usage, only: :create

      def create
        user = User.find_by(email: session_params[:email].to_s.downcase)

        unless user&.authenticate(session_params[:password])
          return render_error("invalid_credentials", "Email or password is incorrect.", status: :unauthorized)
        end
        if !user.patient? && user.clinic&.suspended?
          return render_error("clinic_suspended", "This clinic account is suspended.", status: :payment_required)
        end

        access_token, raw_token = ApiAccessToken.generate!(
          user: user,
          name: session_params[:device_name].presence || default_device_name,
          expires_at: 30.days.from_now
        )

        render json: {
          data: {
            token: raw_token,
            token_type: "Bearer",
            expires_at: access_token.expires_at,
            user: UserSerializer.call(user)
          }
        }, status: :created
      end

      def destroy
        @current_api_token&.revoke!
        head :no_content
      end

      private

      def session_params
        params.require(:session).permit(:email, :password, :device_name)
      end

      def default_device_name
        request.user_agent.presence || "API client"
      end
    end
  end
end
