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

  has_many :appointments, dependent: :destroy
  has_many :treatment_records, dependent: :destroy
  has_many :dental_chart_entries, dependent: :restrict_with_exception
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

  private

  def role_permission
    @role_permission ||= RolePermission.find_by(role: role)
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
