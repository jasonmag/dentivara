class DocumentTemplate < ApplicationRecord
  KINDS = %w[prescription dental_certificate other].freeze
  DEFAULT_PRESCRIPTION_HEADER = "{{clinic_name}}\n{{clinic_address}}\n{{clinic_contact_number}}".freeze
  DEFAULT_PRESCRIPTION_INFORMATION_HEADER = <<~TEXT.freeze
    Patient Name: {{patient_name}}
    Date: {{today}}
    Age: {{patient_age}}
    Gender: {{patient_gender}}
    Weight: {{patient_weight}}
    Diagnosis: {{diagnosis}}
  TEXT
  DEFAULT_PRESCRIPTION_BODY = <<~TEXT.freeze
    {{medication}}

    Sig: {{dosage}}
    Duration: {{duration}}
    Instructions: {{instructions}}
    Follow-up: {{next_visit}}
  TEXT
  DEFAULT_PRESCRIPTION_FOOTER = "{{clinic_name}}\n{{clinic_address}}\n{{clinic_contact_number}}".freeze

  has_one_attached :logo

  scope :kept, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }

  validates :name, :kind, presence: true
  validates :kind, inclusion: { in: KINDS }
  validate :default_for_prescription_must_be_prescription_kind
  validate :single_default_for_prescription

  before_validation :apply_prescription_defaults, if: :prescription_kind?

  def render_for(patient:, dentist:, context: {})
    clinic_defaults = {
      clinic_name: ENV.fetch("CLINIC_NAME", "Dentivara Dental Clinic"),
      clinic_address: ENV.fetch("CLINIC_ADDRESS", "123 Dental Street, Makati City, NCR"),
      clinic_contact_number: ENV.fetch("CLINIC_CONTACT_NUMBER", "+63 2 8123 4567")
    }

    resolved_diagnosis = context[:diagnosis].presence || patient.try(:chief_complaint).presence || "Dental consultation"

    merged = {
      patient_name: patient.full_name,
      patient_id: patient.id,
      patient_age: patient_age(patient),
      patient_gender: context[:patient_gender].presence || patient.try(:gender).presence,
      patient_weight: context[:patient_weight].presence || patient.try(:weight).presence,
      dentist_name: dentist&.name || "Assigned Dentist",
      doctor_name: dentist&.name || "Assigned Doctor",
      today: Date.current.to_s,
      diagnosis: resolved_diagnosis,
      patient_diagnosis: resolved_diagnosis
    }.merge(clinic_defaults).merge(context.transform_keys(&:to_sym))

    rendered_header = interpolate_placeholders(header_text, merged)
    rendered_information_header = interpolate_placeholders(information_header_text, merged)
    rendered_body = interpolate_placeholders(body_template, merged)
    rendered_footer = interpolate_placeholders(footer_text, merged)

    dynamic_signature_name = if kind == "prescription"
      dentist&.name.presence || "Assigned Doctor"
    else
      digital_signature_name.to_s
    end

    dynamic_signature_title = if kind == "prescription"
      "Licensed Dentist"
    else
      digital_signature_title.to_s
    end

    {
      header: rendered_header,
      information_header: rendered_information_header,
      body: rendered_body,
      footer: rendered_footer,
      signature_name: dynamic_signature_name,
      signature_title: dynamic_signature_title
    }
  end

  def soft_delete!
    update!(deleted_at: Time.current, default_for_prescription: false)
  end

  def deleted?
    deleted_at.present?
  end

  private

  def interpolate_placeholders(text, values)
    text.to_s.gsub(/\{\{\s*([a-zA-Z0-9_]+)\s*\}\}/) do
      key = Regexp.last_match(1).to_sym
      values[key].presence || ""
    end
  end

  def patient_age(patient)
    return "" if patient.try(:birth_date).blank?

    today = Date.current
    age = today.year - patient.birth_date.year
    age -= 1 if today < patient.birth_date + age.years
    age
  end

  def prescription_kind?
    kind == "prescription"
  end

  def apply_prescription_defaults
    self.header_text = DEFAULT_PRESCRIPTION_HEADER if header_text.blank?
    self.information_header_text = DEFAULT_PRESCRIPTION_INFORMATION_HEADER if information_header_text.blank?
    self.body_template = DEFAULT_PRESCRIPTION_BODY if body_template.blank?
    self.footer_text = DEFAULT_PRESCRIPTION_FOOTER if footer_text.blank?
    self.digital_signature_name = "Assigned Doctor" if digital_signature_name.blank?
    self.digital_signature_title = "Licensed Dentist" if digital_signature_title.blank?
  end

  def default_for_prescription_must_be_prescription_kind
    return unless default_for_prescription?
    return if kind == "prescription"

    errors.add(:default_for_prescription, "can only be enabled for prescription templates")
  end

  def single_default_for_prescription
    return unless !deleted? && active? && default_for_prescription? && kind == "prescription"

    existing = DocumentTemplate.kept.where(kind: "prescription", active: true, default_for_prescription: true).where.not(id: id)
    errors.add(:default_for_prescription, "already set on another prescription template") if existing.exists?
  end
end
