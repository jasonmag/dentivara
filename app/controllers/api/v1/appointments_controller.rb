module Api
  module V1
    class AppointmentsController < BaseController
      before_action -> { authorize_api!(:appointments) }
      before_action :set_appointment, only: %i[show update destroy]

      def index
        appointments = tenant_scope(Appointment).includes(:patient, :user).order(starts_at: :asc)
        appointments = appointments.where(patient_id: params[:patient_id]) if params[:patient_id].present?
        appointments = appointments.where(user_id: params[:user_id]) if params[:user_id].present?
        appointments = appointments.where(status: params[:status]) if params[:status].present?
        appointments = appointments.where(starts_at: Date.parse(params[:date]).all_day) if params[:date].present?
        appointments = appointments.where("starts_at >= ?", Time.zone.parse(params[:starts_from])) if params[:starts_from].present?
        appointments = appointments.where("starts_at <= ?", Time.zone.parse(params[:starts_to])) if params[:starts_to].present?

        render_collection(appointments, serializer: AppointmentSerializer)
      end

      def show
        render_resource(@appointment, serializer: AppointmentSerializer)
      end

      def create
        appointment = tenant_scope(Appointment).new(appointment_params)
        if appointment.save
          render_resource(appointment, serializer: AppointmentSerializer, status: :created)
        else
          render_validation_errors(appointment)
        end
      end

      def update
        if @appointment.update(appointment_params)
          render_resource(@appointment, serializer: AppointmentSerializer)
        else
          render_validation_errors(@appointment)
        end
      end

      def destroy
        @appointment.destroy
        head :no_content
      end

      private

      def set_appointment
        @appointment = tenant_scope(Appointment).includes(:patient, :user).find(params[:id])
      end

      def appointment_params
        params.require(:appointment).permit(
          :patient_id,
          :user_id,
          :clinic_service_id,
          :duration_minutes,
          :buffer_minutes,
          :preferred_user_id,
          :time_preference,
          :source,
          :booking_type,
          :starts_at,
          :ends_at,
          :status,
          :operatory,
          :cancellation_reason,
          :rescheduled_from_appointment_id,
          :notes
        )
      end
    end
  end
end
