json.extract! invoice, :id, :patient_id, :treatment_record_id, :status, :total_amount, :balance_amount, :issued_on, :approved_by_dentist_at, :approved_by_admin_at, :created_at, :updated_at
json.url invoice_url(invoice, format: :json)
