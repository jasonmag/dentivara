module Portal
  class IntakeFormsController < BaseController
    def index
      @intake_forms = IntakeFormSubmission.where(patient: current_patient).order(created_at: :desc)
    end

    def new
      @intake_form = IntakeFormSubmission.new
    end

    def create
      @intake_form = IntakeFormSubmission.new(intake_form_params)
      @intake_form.patient = current_patient
      @intake_form.submitted_by_user = current_user
      @intake_form.source = "online"
      @intake_form.status = "submitted"

      if @intake_form.save
        redirect_to portal_intake_forms_path, notice: "Intake form submitted successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def intake_form_params
      input = params.require(:intake_form_submission).permit(:chief_concern, :allergies, :current_medication, :preferred_contact)
      payload = input.to_h
      { payload: payload }
    end
  end
end
