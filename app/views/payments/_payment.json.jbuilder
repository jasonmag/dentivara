json.extract! payment, :id, :invoice_id, :amount, :paid_on, :method, :reference_code, :created_at, :updated_at
json.url payment_url(payment, format: :json)
