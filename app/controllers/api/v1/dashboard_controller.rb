module Api
  module V1
    class DashboardController < BaseController
      before_action :authorize_dashboard!

      def show
        render json: {
          data: {
            patients: patients_payload,
            appointments: appointments_payload,
            invoices: invoices_payload
          }
        }
      end

      private

      def authorize_dashboard!
        return if current_user&.can_access?(:patients, :view) &&
          current_user&.can_access?(:appointments, :view) &&
          current_user&.can_access?(:invoices, :view)

        render_error("forbidden", "You are not authorized to access this resource.", status: :forbidden)
      end

      def patients_payload
        per_page = dashboard_limit(:patients_per_page, 5)
        patients = tenant_scope(Patient).order(:last_name, :first_name)

        collection_payload(
          records: patients.limit(per_page),
          total_count: patients.count,
          per_page: per_page
        ) do |patient|
          {
            id: patient.id,
            first_name: patient.first_name,
            last_name: patient.last_name,
            full_name: patient.full_name,
            phone: patient.phone,
            email: patient.email
          }
        end
      end

      def appointments_payload
        per_page = dashboard_limit(:appointments_per_page, 6)
        appointments = tenant_scope(Appointment)
          .includes(:patient, :user)
          .where("starts_at >= ?", starts_from)
          .order(starts_at: :asc)

        collection_payload(
          records: appointments.limit(per_page),
          total_count: appointments.count,
          per_page: per_page
        ) do |appointment|
          {
            id: appointment.id,
            patient_id: appointment.patient_id,
            user_id: appointment.user_id,
            starts_at: appointment.starts_at,
            ends_at: appointment.ends_at,
            status: appointment.status,
            patient: AppointmentSerializer.compact_patient(appointment.patient),
            user: AppointmentSerializer.compact_user(appointment.user)
          }
        end
      end

      def invoices_payload
        per_page = dashboard_limit(:invoices_per_page, 5)
        invoices = tenant_scope(Invoice)
          .includes(:patient)
          .where("issued_on >= ?", issued_from)
          .order(updated_at: :desc)

        collection_payload(
          records: invoices.limit(per_page),
          total_count: invoices.count,
          per_page: per_page
        ) do |invoice|
          {
            id: invoice.id,
            invoice_number: invoice.invoice_number,
            patient_id: invoice.patient_id,
            status: invoice.status,
            total_amount: invoice.total_amount,
            balance_amount: invoice.balance_amount,
            issued_on: invoice.issued_on,
            patient: AppointmentSerializer.compact_patient(invoice.patient),
            updated_at: invoice.updated_at
          }
        end
      end

      def collection_payload(records:, total_count:, per_page:)
        {
          data: records.map { |record| yield(record) },
          meta: {
            pagination: {
              page: 1,
              per_page: per_page,
              total_count: total_count,
              total_pages: (total_count.to_f / per_page).ceil
            }
          }
        }
      end

      def dashboard_limit(param_name, default)
        [ positive_integer(params[param_name], default), MAX_PER_PAGE ].min
      end

      def starts_from
        return Time.zone.parse(params[:starts_from]) if params[:starts_from].present?

        Time.current
      end

      def issued_from
        return Date.parse(params[:issued_from]) if params[:issued_from].present?

        Time.zone.today.beginning_of_month
      end
    end
  end
end
