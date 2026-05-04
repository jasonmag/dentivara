json.extract! treatment_record, :id, :patient_id, :user_id, :appointment_id, :service_type, :clinical_notes, :cost, :performed_on, :created_at, :updated_at
json.url treatment_record_url(treatment_record, format: :json)
