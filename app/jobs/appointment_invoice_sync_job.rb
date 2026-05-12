class AppointmentInvoiceSyncJob < ApplicationJob
  queue_as :default

  def perform(appointment_id)
    appointment = Appointment.find_by(id: appointment_id)
    return if appointment.blank?

    Billing::AppointmentInvoiceSync.call(appointment)
  end
end
