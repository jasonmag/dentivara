module Api
  module V1
    class ClinicsController < BaseController
      before_action :require_platform_admin!
      before_action :set_clinic, only: %i[show update destroy]

      def index
        clinics = Clinic.order(created_at: :desc)
        clinics = clinics.where("name LIKE :q OR slug LIKE :q OR contact_email LIKE :q", q: "%#{params[:search]}%") if params[:search].present?
        render_collection(clinics, serializer: ClinicSerializer)
      end

      def show
        render_resource(@clinic, serializer: ClinicSerializer)
      end

      def create
        clinic = Clinic.new(clinic_params)

        if clinic.save
          render_resource(clinic, serializer: ClinicSerializer, status: :created)
        else
          render_validation_errors(clinic)
        end
      end

      def update
        if @clinic.update(clinic_params)
          render_resource(@clinic, serializer: ClinicSerializer)
        else
          render_validation_errors(@clinic)
        end
      end

      def destroy
        @clinic.suspend!
        head :no_content
      end

      private

      def require_platform_admin!
        return if current_user&.system_admin?

        render_error("forbidden", "Only system admins can manage platform clinics.", status: :forbidden)
      end

      def set_clinic
        @clinic = Clinic.find(params[:id])
      end

      def clinic_params
        params.require(:clinic).permit(:name, :slug, :contact_email, :phone, :subscription_plan, :subscription_status, :trial_ends_on)
      end
    end
  end
end
