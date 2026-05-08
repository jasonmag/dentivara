module Api
  module V1
    class AppointmentsController < BaseController
      before_action :set_appointment, only: %i[show update destroy]

      def index
        appointments = Appointment.includes(:patient, :user).order(starts_at: :asc)
        render json: appointments.as_json(include: { patient: { only: %i[id first_name last_name] }, user: { only: %i[id name role] } })
      end

      def show
        render json: @appointment
      end

      def create
        appointment = Appointment.new(appointment_params)
        if appointment.save
          render json: appointment, status: :created
        else
          render json: { errors: appointment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @appointment.update(appointment_params)
          render json: @appointment
        else
          render json: { errors: @appointment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @appointment.destroy
        head :no_content
      end

      private

      def set_appointment
        @appointment = Appointment.find(params[:id])
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
