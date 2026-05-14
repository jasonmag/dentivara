module Api
  module V1
    class PatientPortalController < BaseController
      before_action :require_patient!

      def show
        links = current_user.patient_links.includes(:clinic, patient: [ :appointments, :invoices, :notifications ])

        render json: {
          data: {
            linked_patients: links.map do |link|
              Current.set(clinic: link.clinic) do
                {
                  clinic: ClinicSerializer.call(link.clinic),
                  patient: PatientSerializer.call(link.patient),
                  appointments: link.patient.appointments.order(starts_at: :desc).limit(10).map { |appointment| AppointmentSerializer.call(appointment) },
                  invoices: link.patient.invoices.order(updated_at: :desc).limit(10).map { |invoice| InvoiceSerializer.call(invoice) },
                  notifications: link.patient.notifications.order(created_at: :desc).limit(10).map { |notification| NotificationSerializer.call(notification) }
                }
              end
            end
          }
        }
      end

      private

      def require_patient!
        return if current_user&.patient?

        render_error("forbidden", "Only patient portal users can access this resource.", status: :forbidden)
      end
    end
  end
end
