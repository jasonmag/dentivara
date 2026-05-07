class PrescriptionsController < ApplicationController
  require "base64"
  require "stringio"

  before_action :set_patient
  before_action :set_prescription, only: %i[show finalize sign]
  before_action :require_prescription_writer!, only: %i[index show new create finalize render_template]
  before_action :require_dentist_signer!, only: :sign

  def index
    @prescriptions = @patient.prescriptions.recent_first
  end

  def show
    @rendered_prescription = prescription_preview_payload(@prescription)
  end

  def new
    @prescription = @patient.prescriptions.new(
      issued_on: Date.current,
      document_template: default_prescription_template
    )
    @templates = DocumentTemplate.where(kind: "prescription").order(:name)
    if @prescription.document_template.present? && @prescription.body.blank?
      rendered = @prescription.document_template.render_for(patient: @patient, dentist: current_prescribing_doctor)
      @prescription.body = compose_prescription_content(rendered)
    end
  end

  def create
    @templates = DocumentTemplate.where(kind: "prescription").order(:name)
    @prescription = @patient.prescriptions.new(prescription_params)
    @prescription.document_template ||= default_prescription_template
    @prescription.drafted_by_user = current_user
    @prescription.status = "draft"

    if @prescription.body.blank? && @prescription.document_template.present?
      rendered = @prescription.document_template.render_for(patient: @patient, dentist: current_prescribing_doctor)
      @prescription.body = compose_prescription_content(rendered)
    end

    if @prescription.save
      redirect_to [@patient, @prescription], notice: "Prescription draft created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def render_template
    template_id = params[:document_template_id].to_s
    template = DocumentTemplate.find_by(id: template_id, kind: "prescription")
    return render json: { body: "" } if template.blank?

    rendered = template.render_for(patient: @patient, dentist: current_prescribing_doctor)
    render json: { body: compose_prescription_content(rendered) }
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

  def current_prescribing_doctor
    return current_user if current_user&.dentist?

    assigned_dentist || current_user
  end

  def default_prescription_template
    @default_prescription_template ||= DocumentTemplate.find_by(kind: "prescription", default_for_prescription: true)
  end

  def compose_prescription_content(rendered)
    [rendered[:information_header], rendered[:body]].reject(&:blank?).join("\n\n")
  end

  def prescription_preview_payload(prescription)
    doctor = prescription.signed_by_user || assigned_dentist || prescription.drafted_by_user

    if prescription.document_template.present?
      rendered = prescription.document_template.render_for(
        patient: @patient,
        dentist: doctor,
        context: { today: prescription.issued_on.to_s }
      )
      information_header, body = split_prescription_content(prescription.body, rendered)
      rendered[:information_header] = information_header if information_header.present?
      rendered[:body] = body
      rendered
    else
      clinic_name = ENV.fetch("CLINIC_NAME", "Dentivara Dental Clinic")
      clinic_address = ENV.fetch("CLINIC_ADDRESS", "123 Dental Street, Makati City, NCR")
      clinic_contact_number = ENV.fetch("CLINIC_CONTACT_NUMBER", "+63 2 8123 4567")

      {
        header: [clinic_name, clinic_address, clinic_contact_number].join("\n"),
        information_header: [
          "Patient Name: #{@patient.full_name}",
          "Date: #{prescription.issued_on}",
          "Diagnosis: #{@patient.chief_complaint.presence || "Dental consultation"}"
        ].join("\n"),
        body: prescription.body,
        footer: [clinic_name, clinic_address, clinic_contact_number].join("\n"),
        signature_name: doctor&.name || "Assigned Doctor",
        signature_title: "Licensed Dentist"
      }
    end
  end

  def split_prescription_content(body, rendered)
    text = body.to_s.strip
    header = rendered[:header].to_s.strip
    information_header = rendered[:information_header].to_s.strip
    footer = rendered[:footer].to_s.strip

    text = text.delete_prefix(header).strip if header.present? && text.start_with?(header)
    text = text.delete_suffix(footer).strip if footer.present? && text.end_with?(footer)
    if information_header.present? && text.start_with?(information_header)
      text = text.delete_prefix(information_header).strip
      return [information_header, text.presence || rendered[:body]]
    end

    if text.include?("\n\n")
      custom_information_header, custom_body = text.split(/\n{2,}/, 2)
      return [custom_information_header.strip, custom_body.strip] if custom_body.present?
    end

    [information_header, text.presence || rendered[:body]]
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
