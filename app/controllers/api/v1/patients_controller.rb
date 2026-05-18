module Api
  module V1
    class PatientsController < BaseController
      before_action -> { authorize_api!(:patients) }
      before_action :set_patient, only: %i[show update destroy]

      def index
        patients = tenant_scope(Patient).order(:last_name, :first_name)
        patients = patients.where("first_name LIKE :q OR last_name LIKE :q OR email LIKE :q OR phone LIKE :q", q: "%#{params[:search]}%") if params[:search].present?

        render_collection(patients, serializer: PatientSerializer)
      end

      def show
        render_resource(@patient, serializer: PatientSerializer)
      end

      def create
        patient = tenant_scope(Patient).new(patient_params)
        if patient.save
          send_claim_invite(patient) if patient.email.present?
          render_resource(patient, serializer: PatientSerializer, status: :created)
        else
          render_validation_errors(patient)
        end
      end

      def update
        if @patient.update(patient_params)
          render_resource(@patient, serializer: PatientSerializer)
        else
          render_validation_errors(@patient)
        end
      end

      def destroy
        @patient.destroy
        head :no_content
      end

      private

      def set_patient
        @patient = tenant_scope(Patient).find(params[:id])
      end

      def patient_params
        params.require(:patient).permit(
          :first_name,
          :last_name,
          :birth_date,
          :phone,
          :email,
          :emergency_contact_name,
          :emergency_contact_phone,
          :medical_history,
          :consented_at,
          :chief_complaint,
          :known_allergies,
          :current_medications,
          :medical_conditions,
          :last_dental_visit_on,
          :address_line1,
          :address_line2,
          :city,
          :state,
          :postal_code,
          :country,
          :preferred_contact_method,
          :insurance_provider,
          :insurance_policy_number
        )
      end

      def send_claim_invite(patient)
        invite, raw_token = PatientClaimInvite.issue!(patient)
        PatientMailer.with(patient: patient, token: raw_token).claim_invite.deliver_later
      rescue StandardError => error
        Rails.logger.warn("Unable to send patient claim invite for patient #{patient.id}: #{error.class}: #{error.message}")
      end
    end
  end
end
