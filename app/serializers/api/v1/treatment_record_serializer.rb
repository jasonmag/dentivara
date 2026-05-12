module Api
  module V1
    class TreatmentRecordSerializer
      def self.call(record)
        {
          id: record.id,
          patient_id: record.patient_id,
          user_id: record.user_id,
          appointment_id: record.appointment_id,
          service_type: record.service_type,
          clinical_notes: record.clinical_notes,
          cost: record.cost,
          performed_on: record.performed_on,
          patient: AppointmentSerializer.compact_patient(record.patient),
          user: AppointmentSerializer.compact_user(record.user),
          appointment: compact_appointment(record.appointment),
          created_at: record.created_at,
          updated_at: record.updated_at
        }
      end

      def self.compact_appointment(appointment)
        return nil if appointment.blank?

        {
          id: appointment.id,
          starts_at: appointment.starts_at,
          ends_at: appointment.ends_at,
          status: appointment.status
        }
      end
    end
  end
end
