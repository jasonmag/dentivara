module Api
  module V1
    class PatientClaimInvitesController < BaseController
      before_action -> { authorize_api!(:patients, :update) }

      def create
        patient = tenant_scope(Patient).find(invite_params[:patient_id])
        return render_error("validation_failed", "Patient email is required before sending a portal invite.", status: :unprocessable_entity) if patient.email.blank?

        invite, raw_token = PatientClaimInvite.issue!(patient)
        PatientMailer.with(patient: patient, token: raw_token).claim_invite.deliver_later

        render json: {
          data: {
            id: invite.id,
            patient_id: patient.id,
            expires_at: invite.expires_at
          }
        }, status: :created
      end

      private

      def invite_params
        params.require(:patient_claim_invite).permit(:patient_id)
      end
    end
  end
end
