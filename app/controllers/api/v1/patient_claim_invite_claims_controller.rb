module Api
  module V1
    class PatientClaimInviteClaimsController < BaseController
      skip_before_action :authenticate_api!, only: :create
      skip_after_action :record_api_token_usage, only: :create

      def create
        invite = PatientClaimInvite.authenticate(claim_params[:token].to_s)
        return render_error("not_found", "This patient portal invite is invalid or expired.", status: :not_found) if invite.blank?

        patient = invite.patient
        return render_error("validation_failed", "This patient record does not have an email address.", status: :unprocessable_entity) if patient.email.blank?
        return render_identity_error unless identity_matches?(patient)

        user = nil
        access_token = nil
        raw_token = nil

        Patient.transaction do
          user = find_or_create_patient_user!(patient)
          link = PatientLink.find_or_initialize_by(patient: patient, user: user)
          link.clinic = patient.clinic
          link.claimed_at ||= Time.current
          link.save!

          patient.update!(user: user, claimed_at: link.claimed_at) if patient.user_id.blank?
          invite.mark_claimed!
          access_token, raw_token = ApiAccessToken.generate!(
            user: user,
            name: "Dentivara Patient Portal",
            expires_at: 30.days.from_now
          )
        end

        render json: {
          data: {
            user: UserSerializer.call(user),
            patient: PatientSerializer.call(patient.reload),
            token: raw_token,
            token_type: "Bearer",
            expires_at: access_token.expires_at
          }
        }, status: :created
      rescue ActiveRecord::RecordInvalid => error
        render_validation_errors(error.record)
      end

      private

      def claim_params
        params.require(:patient_claim_invite_claim).permit(:token, :last_name, :birth_date, :phone_last4, :password, :password_confirmation)
      end

      def identity_matches?(patient)
        return false unless patient.last_name.to_s.casecmp?(claim_params[:last_name].to_s.strip)

        if patient.birth_date.present?
          return false unless claim_params[:birth_date].present?
          return false unless Date.iso8601(claim_params[:birth_date].to_s) == patient.birth_date
        end

        if patient.phone.present?
          expected_last4 = patient.phone.to_s.gsub(/\D/, "").last(4)
          return false if expected_last4.present? && claim_params[:phone_last4].to_s.gsub(/\D/, "") != expected_last4
        end

        true
      rescue Date::Error
        false
      end

      def find_or_create_patient_user!(patient)
        email = patient.email.to_s.downcase
        password = claim_params[:password].to_s
        password_confirmation = claim_params[:password_confirmation].to_s
        return password_error if password.length < 8 || password != password_confirmation

        user = User.find_by(email: email)
        if user.present?
          return existing_user_error unless user.patient?
          return password_error unless user.authenticate(password)

          return user
        end

        User.create!(
          clinic: patient.clinic,
          name: patient.full_name,
          email: email,
          role: :patient,
          password: password,
          password_confirmation: password_confirmation
        )
      end

      def render_identity_error
        render_error("identity_verification_failed", "The invite details do not match this patient record.", status: :unprocessable_entity)
      end

      def password_error
        raise ActiveRecord::RecordInvalid.new(User.new.tap { |user| user.errors.add(:password, "must be at least 8 characters and match confirmation") })
      end

      def existing_user_error
        raise ActiveRecord::RecordInvalid.new(User.new.tap { |user| user.errors.add(:email, "is already used by another account") })
      end
    end
  end
end
