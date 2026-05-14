module Api
  module V1
    class PatientClaimsController < BaseController
      def create
        return render_error("forbidden", "Only patient portal users can claim patient records.", status: :forbidden) unless current_user.patient?

        patient = Patient.unscoped.find_by(claim_code: patient_claim_params[:claim_code].to_s.strip.upcase)
        return render_error("not_found", "No patient record matches that claim code.", status: :not_found) if patient.blank?

        link = PatientLink.find_or_initialize_by(patient: patient, user: current_user)
        link.clinic = patient.clinic
        link.claimed_at ||= Time.current

        if link.save
          patient.update!(user: current_user, claimed_at: link.claimed_at) if patient.user_id.blank?
          render json: {
            data: {
              patient: PatientSerializer.call(patient),
              clinic: ClinicSerializer.call(patient.clinic)
            }
          }, status: :created
        else
          render_validation_errors(link)
        end
      end

      private

      def patient_claim_params
        params.require(:patient_claim).permit(:claim_code)
      end
    end
  end
end
