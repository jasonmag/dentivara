class PatientLink < ApplicationRecord
  belongs_to :patient
  belongs_to :user
  belongs_to :clinic

  validates :claimed_at, presence: true
  validates :patient_id, uniqueness: { scope: :user_id }
  validate :patient_and_link_clinic_match
  validate :user_is_patient

  private

  def patient_and_link_clinic_match
    return if patient.blank? || clinic.blank? || patient.clinic_id == clinic.id

    errors.add(:clinic, "must match the patient clinic")
  end

  def user_is_patient
    return if user.blank? || user.patient?

    errors.add(:user, "must be a patient portal user")
  end
end
