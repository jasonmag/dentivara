module Api
  module V1
    class PlatformSettingsController < BaseController
      before_action :require_system_admin!

      def show
        render json: { data: serialized_settings }
      end

      def update
        setting = ClinicSetting.current

        if setting.update(platform_setting_params)
          render json: { data: serialized_settings(setting) }
        else
          render_validation_errors(setting)
        end
      end

      private

      def require_system_admin!
        return if current_user&.system_admin?

        render_error("forbidden", "Only system admins can manage platform settings.", status: :forbidden)
      end

      def serialized_settings(setting = ClinicSetting.current)
        {
          currency_code: setting.currency_code,
          currency_options: ClinicSetting::CURRENCY_OPTIONS.map do |code, config|
            {
              code: code,
              label: config.fetch(:label),
              symbol: config.fetch(:symbol)
            }
          end
        }
      end

      def platform_setting_params
        params.require(:platform_setting).permit(:currency_code)
      end
    end
  end
end
