module Portal
  class BaseController < ApplicationController
    before_action :require_patient_role

    private

    def require_patient_role
      return if current_user&.patient? && current_user.patient.present?

      redirect_to root_path, alert: "Patient portal requires a linked patient account."
    end

    def current_patient
      @current_patient ||= current_user&.patient
    end
    helper_method :current_patient
  end
end
