json.extract! appointment, :id, :patient_id, :user_id, :source, :booking_type, :starts_at, :ends_at, :status, :notes, :created_at, :updated_at
json.url appointment_url(appointment, format: :json)
