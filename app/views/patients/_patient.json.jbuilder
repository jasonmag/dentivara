json.extract! patient, :id, :first_name, :last_name, :birth_date, :phone, :email, :emergency_contact_name, :emergency_contact_phone, :medical_history, :consented_at, :created_at, :updated_at
json.url patient_url(patient, format: :json)
