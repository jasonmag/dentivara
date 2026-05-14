module Api
  module V1
    class ClinicContextController < BaseController
      def update
        clinic = current_user.accessible_clinics.find_by(id: clinic_context_params[:clinic_id])
        return render_error("forbidden", "You are not authorized to access this clinic.", status: :forbidden) if clinic.blank?
        return render_error("clinic_suspended", "This clinic account is suspended.", status: :payment_required) if clinic.suspended?

        Current.clinic = clinic
        render json: {
          data: {
            clinic: ClinicSerializer.call(clinic),
            user: UserSerializer.call(current_user)
          }
        }
      end

      private

      def clinic_context_params
        params.require(:clinic_context).permit(:clinic_id)
      end
    end
  end
end
