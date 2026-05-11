module Api
  module V1
    class AppointmentSerializer
      def self.call(appointment)
        {
          id: appointment.id,
          patient_id: appointment.patient_id,
          user_id: appointment.user_id,
          clinic_service_id: appointment.clinic_service_id,
          duration_minutes: appointment.duration_minutes,
          buffer_minutes: appointment.buffer_minutes,
          preferred_user_id: appointment.preferred_user_id,
          time_preference: appointment.time_preference,
          source: appointment.source,
          booking_type: appointment.booking_type,
          starts_at: appointment.starts_at,
          ends_at: appointment.ends_at,
          status: appointment.status,
          operatory: appointment.operatory,
          cancellation_reason: appointment.cancellation_reason,
          cancelled_at: appointment.cancelled_at,
          rescheduled_from_appointment_id: appointment.rescheduled_from_appointment_id,
          notes: appointment.notes,
          patient: compact_patient(appointment.patient),
          user: compact_user(appointment.user),
          created_at: appointment.created_at,
          updated_at: appointment.updated_at
        }
      end

      def self.compact_patient(patient)
        return nil if patient.blank?

        {
          id: patient.id,
          first_name: patient.first_name,
          last_name: patient.last_name,
          full_name: patient.full_name
        }
      end

      def self.compact_user(user)
        return nil if user.blank?

        {
          id: user.id,
          name: user.name,
          role: user.role
        }
      end
    end
  end
end
