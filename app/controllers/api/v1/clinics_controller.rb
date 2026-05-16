module Api
  module V1
    class ClinicsController < BaseController
      before_action :require_platform_admin!, only: %i[show update destroy]
      before_action :require_clinic_owner_or_platform_admin!, only: %i[create]
      before_action :set_clinic, only: %i[show update destroy]

      def index
        clinics = current_user.system_admin? ? Clinic.all : current_user.accessible_clinics
        clinics = clinics.order(created_at: :desc)
        clinics = clinics.where("name LIKE :q OR slug LIKE :q OR contact_email LIKE :q", q: "%#{params[:search]}%") if params[:search].present?
        render_collection(clinics, serializer: ClinicSerializer)
      end

      def show
        render_resource(@clinic, serializer: ClinicSerializer)
      end

      def create
        if current_user&.clinic_owner? && !owner_account&.subscription_allows_clinic_addition?
          return render_error(
            "clinic_limit_reached",
            "Your current subscription does not allow another clinic.",
            status: :unprocessable_entity
          )
        end

        clinic = Clinic.new(clinic_params)
        clinic.account ||= owner_account if current_user&.clinic_owner?

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

      def require_clinic_owner_or_platform_admin!
        return if current_user&.system_admin? || current_user&.clinic_owner?

        render_error("forbidden", "Only client owners can add clinics.", status: :forbidden)
      end

      def set_clinic
        @clinic = Clinic.find(params[:id])
      end

      def clinic_params
        permitted = [ :name, :slug, :contact_email, :phone, :subscription_status, :trial_ends_on ]
        permitted << :account_id if current_user&.system_admin?
        params.require(:clinic).permit(permitted)
      end

      def owner_account
        @owner_account ||= current_user.accessible_accounts.order(:id).first || current_user.clinic&.account
      end
    end
  end
end
