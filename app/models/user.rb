class User < ApplicationRecord
  include Auditable

  PERMISSION_ACTIONS = %w[view create update destroy].freeze
  PERMISSION_FEATURES = {
    patients: "Patients",
    appointments: "Appointments",
    treatment_records: "Treatment Records",
    prescriptions: "Prescriptions",
    dental_chart_entries: "Dental Chart",
    invoices: "Invoices",
    payments: "Payments",
    notifications: "Notifications",
    clinic_services: "Services",
    document_templates: "Documents",
    users: "Users",
    audit_logs: "Audit Logs",
    compliance: "Compliance",
    reports: "Reports"
  }.freeze

  belongs_to :clinic
  before_validation :assign_default_clinic
  after_create :ensure_primary_clinic_membership
  before_destroy :release_foreign_key_references

  has_many :clinic_memberships, dependent: :destroy
  has_many :clinics, through: :clinic_memberships
  has_many :account_memberships, dependent: :destroy
  has_many :accounts, through: :account_memberships
  has_many :patient_links, dependent: :destroy
  has_many :linked_patients, through: :patient_links, source: :patient
  has_many :access_logs, dependent: :nullify
  has_many :audit_logs, dependent: :nullify
  has_many :appointments, dependent: :destroy
  has_many :preferred_appointments, class_name: "Appointment", foreign_key: :preferred_user_id, dependent: :nullify
  has_many :api_access_tokens, dependent: :destroy
  has_many :dentist_schedules, dependent: :destroy
  has_many :dentist_schedule_overrides, dependent: :destroy
  has_many :treatment_records, dependent: :destroy
  has_many :dental_chart_entries, dependent: :destroy
  has_many :intake_form_submissions, foreign_key: :submitted_by_user_id, dependent: :nullify
  has_many :intraoral_scans, dependent: :destroy
  has_many :patient_consents, dependent: :destroy
  has_many :drafted_prescriptions, class_name: "Prescription", foreign_key: :drafted_by_user_id, dependent: :restrict_with_exception
  has_many :signed_prescriptions, class_name: "Prescription", foreign_key: :signed_by_user_id, dependent: :nullify
  has_one :patient, dependent: :nullify
  has_secure_password validations: false

  enum :role, {
    clinic_owner: 0,
    dentist: 1,
    receptionist: 2,
    billing_staff: 3,
    patient: 4,
    system_admin: 5
  }, default: :receptionist

  validates :name, :email, :role, presence: true
  validates :email, uniqueness: true
  validates :password, length: { minimum: 8 }, allow_nil: true

  def permission_matrix
    role_permission&.permission_matrix || default_permission_matrix
  end

  def can_access?(feature, action = :view)
    return true if system_admin? || clinic_owner?

    permission_matrix.dig(feature.to_s, action.to_s) == true
  end

  def feature_label(feature)
    PERMISSION_FEATURES.fetch(feature.to_sym, feature.to_s.humanize)
  end

  def role_default_full_access?
    system_admin? || clinic_owner?
  end

  def accessible_clinics
    return Clinic.all if system_admin?
    return Clinic.where(id: patient_links.select(:clinic_id)) if patient?

    Clinic.where(id: clinics.select(:id)).or(Clinic.where(account_id: accounts.select(:id)))
  end

  def accessible_accounts
    system_admin? ? Account.all : accounts
  end

  def can_access_clinic?(clinic)
    return true if system_admin?

    clinic_memberships.exists?(clinic_id: clinic.id)
  end

  private

  def assign_default_clinic
    self.clinic ||= Current.clinic || Clinic.default
  end

  def role_permission
    @role_permission ||= RolePermission.find_by(role: role)
  end

  def ensure_primary_clinic_membership
    clinic_memberships.find_or_create_by!(clinic: clinic) do |membership|
      membership.role = role
      membership.accepted_at = Time.current
    end

    return if patient?

    account_memberships.find_or_create_by!(account: clinic.account) do |membership|
      membership.role = clinic_owner? ? "owner" : "member"
      membership.accepted_at = Time.current
    end
  end

  def release_foreign_key_references
    AccessLog.unscoped.where(user_id: id).update_all(user_id: nil)
    AuditLog.unscoped.where(user_id: id).update_all(user_id: nil)
    Appointment.unscoped.where(preferred_user_id: id).update_all(preferred_user_id: nil)
    IntakeFormSubmission.unscoped.where(submitted_by_user_id: id).update_all(submitted_by_user_id: nil)
    Patient.unscoped.where(user_id: id).update_all(user_id: nil)
    Prescription.unscoped.where(signed_by_user_id: id).update_all(signed_by_user_id: nil)

    appointment_ids = Appointment.unscoped.where(user_id: id).pluck(:id)
    Appointment.unscoped.where(rescheduled_from_appointment_id: appointment_ids).update_all(rescheduled_from_appointment_id: nil) if appointment_ids.any?
    QueueEntry.unscoped.where(appointment_id: appointment_ids).update_all(appointment_id: nil) if appointment_ids.any?
    treatment_record_ids = TreatmentRecord.unscoped.where(appointment_id: appointment_ids).or(TreatmentRecord.unscoped.where(user_id: id)).pluck(:id)
    invoice_ids = Invoice.unscoped.where(treatment_record_id: treatment_record_ids).pluck(:id)
    Payment.unscoped.where(invoice_id: invoice_ids).destroy_all if invoice_ids.any?
    Invoice.unscoped.where(id: invoice_ids).delete_all if invoice_ids.any?
    TreatmentRecord.unscoped.where(id: treatment_record_ids).delete_all if treatment_record_ids.any?

    ApiAccessToken.unscoped.where(user_id: id).delete_all
    Appointment.unscoped.where(id: appointment_ids).delete_all if appointment_ids.any?
    ClinicMembership.unscoped.where(user_id: id).delete_all
    DentalChartEntry.unscoped.where(user_id: id).destroy_all
    DentistSchedule.unscoped.where(user_id: id).destroy_all
    DentistScheduleOverride.unscoped.where(user_id: id).destroy_all
    IntraoralScan.unscoped.where(user_id: id).destroy_all
    PatientConsent.unscoped.where(user_id: id).destroy_all
    Prescription.unscoped.where(drafted_by_user_id: id).destroy_all
  end

  def default_permission_matrix
    PERMISSION_FEATURES.each_with_object({}) do |(feature, _label), matrix|
      matrix[feature.to_s] = PERMISSION_ACTIONS.index_with do |action|
        if patient?
          false
        else
          true
        end
      end
    end
  end
end
