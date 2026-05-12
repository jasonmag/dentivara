module Portal
  class DashboardController < BaseController
    def show
      @patient = current_patient
      @appointments = @patient&.appointments&.order(starts_at: :desc)&.limit(10) || []
      @invoices = @patient&.invoices&.order(updated_at: :desc)&.limit(10) || []
      @notifications = @patient&.notifications&.order(created_at: :desc)&.limit(10) || []
      @intake_forms = IntakeFormSubmission.where(patient: @patient).order(created_at: :desc).limit(10)
    end
  end
end
