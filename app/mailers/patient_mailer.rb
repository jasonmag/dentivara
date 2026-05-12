class PatientMailer < ApplicationMailer
  def patient_notification
    @notification = params.fetch(:notification)
    @patient = @notification.patient

    mail(to: @patient.email, subject: "Dentivara Notification: #{@notification.category.humanize}")
  end

  def billing_balance
    @patient = params.fetch(:patient)
    @invoice = params.fetch(:invoice)

    mail(to: @patient.email, subject: "Dentivara Billing Update ##{@invoice.id}")
  end
end
