class NotificationDispatchJob < ApplicationJob
  queue_as :default

  def perform(notification_id)
    notification = Notification.find_by(id: notification_id)
    return if notification.blank? || notification.sent?

    case notification.channel
    when "email"
      PatientMailer.with(notification: notification).patient_notification.deliver_later
      notification.update!(status: "sent", sent_at: Time.current)
    when "sms", "in_app"
      # Placeholder dispatch for SMS/In-app gateways.
      notification.update!(status: "sent", sent_at: Time.current)
    else
      notification.update!(status: "failed")
    end
  end
end
