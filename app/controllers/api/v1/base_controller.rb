module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_api!
      before_action :ensure_json_request

      private

      def authenticate_api!
        expected_token = ENV.fetch("API_V1_TOKEN", "dev-token")
        provided = request.headers["Authorization"].to_s.delete_prefix("Bearer ")

        return if ActiveSupport::SecurityUtils.secure_compare(provided, expected_token)

        render json: { error: "Unauthorized" }, status: :unauthorized
      end

      def ensure_json_request
        request.format = :json
      end
    end
  end
end
