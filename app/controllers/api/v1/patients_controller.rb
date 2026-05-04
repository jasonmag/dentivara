module Api
  module V1
    class PatientsController < BaseController
      before_action :set_patient, only: %i[show update destroy]

      def index
        render json: Patient.order(:last_name, :first_name)
      end

      def show
        render json: @patient
      end

      def create
        patient = Patient.new(patient_params)
        if patient.save
          render json: patient, status: :created
        else
          render json: { errors: patient.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @patient.update(patient_params)
          render json: @patient
        else
          render json: { errors: @patient.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @patient.destroy
        head :no_content
      end

      private

      def set_patient
        @patient = Patient.find(params[:id])
      end

      def patient_params
        params.require(:patient).permit(:first_name, :last_name, :birth_date, :phone, :email, :emergency_contact_name, :emergency_contact_phone, :medical_history, :consented_at)
      end
    end
  end
end
