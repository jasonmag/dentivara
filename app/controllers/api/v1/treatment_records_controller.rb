module Api
  module V1
    class TreatmentRecordsController < BaseController
      before_action -> { authorize_api!(:treatment_records) }
      before_action :set_treatment_record, only: %i[show update destroy]

      def index
        records = TreatmentRecord.includes(:patient, :user, :appointment).order(performed_on: :desc)
        records = records.where(patient_id: params[:patient_id]) if params[:patient_id].present?
        records = records.where(user_id: params[:user_id]) if params[:user_id].present?
        records = records.where(appointment_id: params[:appointment_id]) if params[:appointment_id].present?
        records = records.where(performed_on: params[:performed_on]) if params[:performed_on].present?

        render_collection(records, serializer: TreatmentRecordSerializer)
      end

      def show
        render_resource(@treatment_record, serializer: TreatmentRecordSerializer)
      end

      def create
        record = TreatmentRecord.new(treatment_record_params)
        record.user ||= current_user if current_user&.dentist?

        if record.save
          render_resource(record, serializer: TreatmentRecordSerializer, status: :created)
        else
          render_validation_errors(record)
        end
      end

      def update
        if @treatment_record.update(treatment_record_params)
          render_resource(@treatment_record, serializer: TreatmentRecordSerializer)
        else
          render_validation_errors(@treatment_record)
        end
      end

      def destroy
        @treatment_record.destroy
        head :no_content
      end

      private

      def set_treatment_record
        @treatment_record = TreatmentRecord.includes(:patient, :user, :appointment).find(params[:id])
      end

      def treatment_record_params
        params.require(:treatment_record).permit(:patient_id, :user_id, :appointment_id, :service_type, :clinical_notes, :cost, :performed_on)
      end
    end
  end
end
