json.extract! appointment, :id, :patient_id, :user_id, :clinic_service_id, :duration_minutes, :buffer_minutes, :preferred_user_id, :time_preference, :source, :booking_type, :starts_at, :ends_at, :status, :operatory, :cancellation_reason, :cancelled_at, :rescheduled_from_appointment_id, :notes, :created_at, :updated_at
json.url appointment_url(appointment, format: :json)
