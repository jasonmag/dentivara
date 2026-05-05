class PatientConsentsController < ApplicationController
  before_action -> { require_roles(:clinic_owner, :system_admin, :dentist, :receptionist) }
  before_action :set_patient

  def create
    consent = @patient.patient_consents.new(consent_params)
    consent.user = current_user

    if consent.save
      redirect_to @patient, notice: "Consent version recorded."
    else
      redirect_to @patient, alert: consent.errors.full_messages.to_sentence
    end
  end

  private

  def set_patient
    @patient = Patient.find(params.expect(:patient_id))
  end

  def consent_params
    params.expect(patient_consent: %i[consent_type document_version consented_at])
  end
end
