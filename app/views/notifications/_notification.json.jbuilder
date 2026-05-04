json.extract! notification, :id, :patient_id, :channel, :category, :scheduled_for, :sent_at, :status, :message, :created_at, :updated_at
json.url notification_url(notification, format: :json)
