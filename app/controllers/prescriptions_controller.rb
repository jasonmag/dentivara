class PrescriptionsController < ApplicationController
  require "base64"
  require "stringio"

  before_action :set_patient
  before_action :set_prescription, only: %i[show finalize sign]
  before_action :require_prescription_writer!, only: %i[index show new create finalize]
  before_action :require_dentist_signer!, only: :sign

  def index
    @prescriptions = @patient.prescriptions.recent_first
  end

  def show
  end

  def new
    @prescription = @patient.prescriptions.new(issued_on: Date.current)
    @templates = DocumentTemplate.where(kind: "prescription").order(:name)
  end

  def create
    @templates = DocumentTemplate.where(kind: "prescription").order(:name)
    @prescription = @patient.prescriptions.new(prescription_params)
    @prescription.drafted_by_user = current_user
    @prescription.status = "draft"

    if @prescription.body.blank? && @prescription.document_template.present?
      rendered = @prescription.document_template.render_for(patient: @patient, dentist: assigned_dentist)
      @prescription.body = [rendered[:header], rendered[:body], rendered[:footer]].reject(&:blank?).join("\n\n")
    end

    if @prescription.save
      redirect_to [@patient, @prescription], notice: "Prescription draft created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def finalize
    unless @prescription.can_finalize?
      return redirect_to [@patient, @prescription], alert: "Only draft prescriptions can be finalized."
    end

    @prescription.update!(status: "finalized")
    redirect_to [@patient, @prescription], notice: "Prescription finalized and ready for dentist signature."
  end

  def sign
    unless @prescription.can_sign?
      return redirect_to [@patient, @prescription], alert: "Only finalized prescriptions can be signed."
    end

    signature_data = params[:signature_data].to_s
    if signature_data.blank?
      return redirect_to [@patient, @prescription], alert: "Please provide a signature before signing."
    end
    unless params[:signature_confirmed] == "1"
      return redirect_to [@patient, @prescription], alert: "Please confirm the signature declaration before signing."
    end

    @prescription.update!(
      status: "signed",
      signed_by_user: current_user,
      signed_at: Time.current,
      signature_snapshot: "Digitally signed by #{current_user.name} (#{current_user.email}) on #{I18n.l(Time.current, format: :long)}"
    )
    attach_signature_image(@prescription, signature_data)

    redirect_to [@patient, @prescription], notice: "Prescription digitally signed."
  end

  private

  def set_patient
    @patient = Patient.find(params.expect(:patient_id))
  end

  def set_prescription
    @prescription = @patient.prescriptions.find(params.expect(:id))
  end

  def prescription_params
    params.expect(prescription: %i[document_template_id issued_on body])
  end

  def assigned_dentist
    @assigned_dentist ||= User.where(role: :dentist).order(:name).first
  end

  def require_prescription_writer!
    require_roles(:clinic_owner, :system_admin, :dentist, :receptionist)
  end

  def require_dentist_signer!
    require_roles(:clinic_owner, :system_admin, :dentist)
  end

  def attach_signature_image(prescription, data_url)
    match = data_url.match(%r{\Adata:(image\/png|image\/jpeg|image\/jpg|image\/webp);base64,(.+)\z}m)
    return unless match

    content_type = match[1]
    encoded_data = match[2]
    decoded_data = Base64.decode64(encoded_data)
    extension = case content_type
                when "image/png" then "png"
                when "image/webp" then "webp"
                else "jpg"
                end

    prescription.signature_image.attach(
      io: StringIO.new(decoded_data),
      filename: "prescription-signature-#{prescription.id}-#{Time.current.to_i}.#{extension}",
      content_type: content_type
    )
  rescue ArgumentError
    nil
  end
end
