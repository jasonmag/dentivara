class DocumentTemplatesController < ApplicationController
  before_action :set_document_template, only: %i[show edit update destroy preview]
  before_action -> { require_roles(:clinic_owner, :system_admin, :dentist, :receptionist) }

  def index
    @document_templates = DocumentTemplate.order(:kind, :name)
  end

  def show; end

  def new
    @document_template = DocumentTemplate.new
  end

  def edit; end

  def create
    @document_template = DocumentTemplate.new(document_template_params)

    if @document_template.save
      redirect_to @document_template, notice: "Document template created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @document_template.update(document_template_params)
      redirect_to @document_template, notice: "Document template updated successfully.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @document_template.destroy!
    redirect_to document_templates_path, notice: "Document template deleted successfully.", status: :see_other
  end

  def preview
    patient = Patient.order(:id).first
    dentist = User.dentist.first || User.order(:id).first
    @rendered = @document_template.render_for(patient: patient, dentist: dentist, context: params.fetch(:context, {}).to_h)
  end

  private

  def set_document_template
    @document_template = DocumentTemplate.find(params.expect(:id))
  end

  def document_template_params
    params.expect(document_template: %i[name kind header_text body_template footer_text digital_signature_name digital_signature_title active])
  end
end
