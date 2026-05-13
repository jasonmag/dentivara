module Api
  module V1
    class ClinicServicesController < BaseController
      before_action -> { authorize_api!(:clinic_services) }
      before_action :set_clinic_service, only: %i[show update destroy]

      def index
        clinic_services = ClinicService.order(:name)
        clinic_services = clinic_services.where("name LIKE :q OR description LIKE :q", q: "%#{params[:search]}%") if params[:search].present?

        render_collection(clinic_services, serializer: ClinicServiceSerializer)
      end

      def show
        render_resource(@clinic_service, serializer: ClinicServiceSerializer)
      end

      def create
        clinic_service = ClinicService.new(clinic_service_params)

        if clinic_service.save
          render_resource(clinic_service, serializer: ClinicServiceSerializer, status: :created)
        else
          render_validation_errors(clinic_service)
        end
      end

      def update
        if @clinic_service.update(clinic_service_params)
          render_resource(@clinic_service, serializer: ClinicServiceSerializer)
        else
          render_validation_errors(@clinic_service)
        end
      end

      def destroy
        @clinic_service.destroy
        head :no_content
      end

      private

      def set_clinic_service
        @clinic_service = ClinicService.find(params[:id])
      end

      def clinic_service_params
        params.require(:clinic_service).permit(:name, :description, :base_price, :active, :duration_minutes, :preparation_minutes, :color)
      end
    end
  end
end
