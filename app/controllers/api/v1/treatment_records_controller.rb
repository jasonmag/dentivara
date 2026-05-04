module Api
  module V1
    class TreatmentRecordsController < BaseController
      before_action :set_treatment_record, only: %i[show update destroy]

      def index
        records = TreatmentRecord.includes(:patient, :user, :appointment).order(performed_on: :desc)
        render json: records.as_json(include: { patient: { only: %i[id first_name last_name] }, user: { only: %i[id name] }, appointment: { only: %i[id starts_at status] } })
      end

      def show
        render json: @treatment_record
      end

      def create
        record = TreatmentRecord.new(treatment_record_params)
        if record.save
          render json: record, status: :created
        else
          render json: { errors: record.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @treatment_record.update(treatment_record_params)
          render json: @treatment_record
        else
          render json: { errors: @treatment_record.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @treatment_record.destroy
        head :no_content
      end

      private

      def set_treatment_record
        @treatment_record = TreatmentRecord.find(params[:id])
      end

      def treatment_record_params
        params.require(:treatment_record).permit(:patient_id, :user_id, :appointment_id, :service_type, :clinical_notes, :cost, :performed_on)
      end
    end
  end
end
