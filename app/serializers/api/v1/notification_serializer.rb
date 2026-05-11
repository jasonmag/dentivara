module Api
  module V1
    class NotificationSerializer
      def self.call(notification)
        {
          id: notification.id,
          patient_id: notification.patient_id,
          channel: notification.channel,
          category: notification.category,
          scheduled_for: notification.scheduled_for,
          sent_at: notification.sent_at,
          status: notification.status,
          message: notification.message,
          source_record_type: notification.source_record_type,
          source_record_id: notification.source_record_id,
          patient: AppointmentSerializer.compact_patient(notification.patient),
          created_at: notification.created_at,
          updated_at: notification.updated_at
        }
      end
    end
  end
end
