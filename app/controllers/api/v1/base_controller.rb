module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_api!
      before_action :ensure_json_request

      private

      def authenticate_api!
        expected_token = expected_api_token
        provided = request.headers["Authorization"].to_s.delete_prefix("Bearer ")

        return if expected_token.present? && ActiveSupport::SecurityUtils.secure_compare(provided, expected_token)

        render json: { error: "Unauthorized" }, status: :unauthorized
      end

      def ensure_json_request
        request.format = :json
      end

      def expected_api_token
        token = ENV["API_V1_TOKEN"].to_s
        return token if token.present?
        return "dev-token" if Rails.env.development? || Rails.env.test?

        nil
      end
    end
  end
end
