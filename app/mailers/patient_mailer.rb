class PatientMailer < ApplicationMailer
  def claim_invite
    @patient = params.fetch(:patient)
    @clinic = @patient.clinic
    token = params.fetch(:token)
    portal_base_url = ENV.fetch("PATIENT_PORTAL_BASE_URL", "http://localhost:3001").delete_suffix("/")
    @claim_url = "#{portal_base_url}/portal/claim?token=#{CGI.escape(token)}"

    mail(to: @patient.email, subject: "#{@clinic.name} invited you to claim your patient portal")
  end

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
