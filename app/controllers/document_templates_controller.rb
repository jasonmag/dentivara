class DocumentTemplatesController < ApplicationController
  before_action :set_document_template, only: %i[show edit update destroy preview]
  before_action -> { require_roles(:clinic_owner, :system_admin, :dentist, :receptionist) }

  def index
    @document_templates = DocumentTemplate.order(:kind, :name)
  end

  def show
    @rendered_preview = render_preview_payload(@document_template)
  end

  def new
    @document_template = DocumentTemplate.new
  end

  def edit; end

  def create
    @document_template = DocumentTemplate.new(document_template_params)
    normalize_default_for_prescription(@document_template)

    respond_to do |format|
      if @document_template.save
        format.html { redirect_to @document_template, notice: "Document template created successfully." }
        format.turbo_stream { redirect_to @document_template, notice: "Document template created successfully." }
        format.json { render :show, status: :created, location: @document_template }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :new, formats: :html, status: :unprocessable_entity }
        format.json { render json: @document_template.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @document_template.assign_attributes(document_template_params)
    normalize_default_for_prescription(@document_template)

    respond_to do |format|
      if @document_template.save
        format.html { redirect_to @document_template, notice: "Document template updated successfully.", status: :see_other }
        format.turbo_stream { redirect_to @document_template, notice: "Document template updated successfully.", status: :see_other }
        format.json { render :show, status: :ok, location: @document_template }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :edit, formats: :html, status: :unprocessable_entity }
        format.json { render json: @document_template.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @document_template.destroy!
    respond_to do |format|
      format.html { redirect_to document_templates_path, notice: "Document template deleted successfully.", status: :see_other }
      format.turbo_stream { redirect_to document_templates_path, notice: "Document template deleted successfully.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def preview
    @rendered = render_preview_payload(@document_template)
  end

  private

  def set_document_template
    @document_template = DocumentTemplate.find(params.expect(:id))
  end

  def document_template_params
    params.expect(document_template: %i[name kind header_text information_header_text body_template footer_text digital_signature_name digital_signature_title active default_for_prescription logo])
  end

  def render_preview_payload(template)
    patient = Patient.order(:id).first || Patient.new(first_name: "Maria", last_name: "Santos", birth_date: Date.new(1993, 5, 2))
    dentist = User.dentist.first || User.order(:id).first || User.new(name: "Dr. Sample Dentist")

    template.render_for(
      patient: patient,
      dentist: dentist,
      context: {
        medication: "Amoxicillin 500mg capsule",
        dosage: "1 capsule every 8 hours",
        duration: "7 days",
        diagnosis: "Acute pulpitis (tooth 16)",
        patient_gender: "Female",
        patient_weight: "54 kg",
        instructions: "Take after meals; complete full course.",
        next_visit: (Date.current + 7.days).to_s
      }
    )
  end

  def normalize_default_for_prescription(template)
    return unless template.kind == "prescription"

    has_existing_default = DocumentTemplate.where(kind: "prescription", default_for_prescription: true).where.not(id: template.id).exists?
    template.default_for_prescription = true if !has_existing_default && !template.default_for_prescription?
    return unless ActiveModel::Type::Boolean.new.cast(template.default_for_prescription)

    DocumentTemplate.where(kind: "prescription", default_for_prescription: true).where.not(id: template.id).update_all(default_for_prescription: false)
  end
end
