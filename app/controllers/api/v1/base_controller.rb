module Api
  module V1
    class BaseController < ActionController::API
      before_action :ensure_json_request
      before_action :authenticate_api!
      after_action :record_api_token_usage
      after_action :reset_current_context

      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActionController::ParameterMissing, with: :render_parameter_missing
      rescue_from ArgumentError, with: :render_invalid_parameter

      DEFAULT_PER_PAGE = 25
      MAX_PER_PAGE = 100

      private

      def authenticate_api!
        provided = bearer_token
        @current_api_token = ApiAccessToken.authenticate(provided)

        if @current_api_token.present?
          @current_user = @current_api_token.user
          Current.user = @current_user
          Current.clinic = clinic_for_request(@current_user)
          return render_error("forbidden", "You are not authorized to access this clinic.", status: :forbidden) if Current.clinic.blank? && !account_only_api_access?
          return render_error("clinic_suspended", "This clinic account is suspended.", status: :payment_required) if Current.clinic&.suspended? && !account_only_api_access?
          return
        end

        return if authenticate_legacy_token(provided)

        render_error("unauthorized", "A valid bearer token is required.", status: :unauthorized)
      end

      def ensure_json_request
        request.format = :json
      end

      def bearer_token
        authorization = request.headers["Authorization"].to_s
        scheme, token = authorization.split(/\s+/, 2)
        return "" unless scheme&.casecmp("Bearer")&.zero?

        token.to_s
      end

      def authenticate_legacy_token(provided)
        expected_token = legacy_api_token
        return false if expected_token.blank? || provided.blank?
        return false unless ActiveSupport::SecurityUtils.secure_compare(provided, expected_token)

        @current_user = legacy_api_user
        return false if @current_user.blank?

        Current.user = @current_user
        Current.clinic = clinic_for_request(@current_user)
        Current.clinic.present? || account_only_api_access?
      end

      def legacy_api_token
        return nil if Rails.env.in?(%w[production staging]) && ENV["API_V1_LEGACY_TOKEN_ENABLED"] != "true"

        token = ENV["API_V1_TOKEN"].to_s
        return token if token.present?
        return "dev-token" if Rails.env.development? || Rails.env.test?

        nil
      end

      def legacy_api_user
        User.system_admin.first || User.clinic_owner.first || User.first
      end

      def current_user
        @current_user
      end

      def current_api_token
        @current_api_token
      end

      def current_clinic
        Current.clinic || current_user&.clinic
      end

      def account_only_api_access?
        return false unless current_user&.clinic_owner?

        (controller_name == "clinics" && action_name.in?(%w[index create])) ||
          (controller_name == "clinics" && action_name.in?(%w[activate destroy])) ||
          (controller_name == "sessions" && action_name == "show") ||
          (controller_name == "users" && action_name == "index") ||
          (controller_name == "account_subscriptions" && action_name.in?(%w[show create]))
      end

      def tenant_scope(model_class)
        model_class.where(clinic_id: current_clinic.id)
      end

      def clinic_for_request(user)
        requested_id = request.headers["X-Clinic-ID"].presence || params[:clinic_id].presence
        return user.clinic if requested_id.blank?

        user.accessible_clinics.find_by(id: requested_id)
      end

      def authorize_api!(feature, action = action_name)
        permission_action = permission_action_for(action)
        return if current_user&.can_access?(feature, permission_action)

        render_error("forbidden", "You are not authorized to access this resource.", status: :forbidden)
      end

      def permission_action_for(action)
        case action.to_s
        when "index", "show"
          :view
        when "create"
          :create
        when "update"
          :update
        when "destroy"
          :destroy
        else
          action
        end
      end

      def render_collection(scope, serializer:)
        page = positive_integer(params[:page], 1)
        per_page = [ positive_integer(params[:per_page], DEFAULT_PER_PAGE), MAX_PER_PAGE ].min
        total_count = scope.count
        records = scope.offset((page - 1) * per_page).limit(per_page)

        render json: {
          data: records.map { |record| serializer.call(record) },
          meta: {
            pagination: {
              page: page,
              per_page: per_page,
              total_count: total_count,
              total_pages: (total_count.to_f / per_page).ceil
            }
          }
        }
      end

      def render_resource(record, serializer:, status: :ok)
        render json: { data: serializer.call(record) }, status: status
      end

      def render_validation_errors(record)
        render json: {
          error: {
            code: "validation_failed",
            message: "Validation failed.",
            details: record.errors.to_hash(true)
          }
        }, status: :unprocessable_entity
      end

      def render_error(code, message, status:, details: nil)
        body = { error: { code: code, message: message } }
        body[:error][:details] = details if details.present?

        render json: body, status: status
      end

      def render_not_found
        render_error("not_found", "The requested resource could not be found.", status: :not_found)
      end

      def render_parameter_missing(error)
        render_error(
          "parameter_missing",
          "A required parameter is missing.",
          status: :bad_request,
          details: { parameter: error.param }
        )
      end

      def render_invalid_parameter(error)
        render_error(
          "invalid_parameter",
          error.message.presence || "One or more parameters are invalid.",
          status: :bad_request
        )
      end

      def positive_integer(value, default)
        integer = value.to_i
        integer.positive? ? integer : default
      end

      def record_api_token_usage
        @current_api_token&.touch_usage!(request)
      end

      def reset_current_context
        Current.reset
      end
    end
  end
end
