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

    respond_to do |format|
      if @document_template.save
        format.html { redirect_to @document_template, notice: "Document template created successfully." }
        format.turbo_stream { redirect_to @document_template, notice: "Document template created successfully." }
        format.json { render :show, status: :created, location: @document_template }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :new, status: :unprocessable_entity }
        format.json { render json: @document_template.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @document_template.update(document_template_params)
        format.html { redirect_to @document_template, notice: "Document template updated successfully.", status: :see_other }
        format.turbo_stream { redirect_to @document_template, notice: "Document template updated successfully.", status: :see_other }
        format.json { render :show, status: :ok, location: @document_template }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :edit, status: :unprocessable_entity }
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
