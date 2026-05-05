class DocumentTemplate < ApplicationRecord
  KINDS = %w[prescription dental_certificate other].freeze

  validates :name, :kind, presence: true
  validates :kind, inclusion: { in: KINDS }

  def render_for(patient:, dentist:, context: {})
    merged = {
      patient_name: patient.full_name,
      patient_id: patient.id,
      dentist_name: dentist&.name || "Assigned Dentist",
      today: Date.current.to_s
    }.merge(context.transform_keys(&:to_sym))

    rendered_body = body_template.to_s.gsub(/\{\{\s*([a-zA-Z0-9_]+)\s*\}\}/) do
      key = Regexp.last_match(1).to_sym
      merged[key].presence || ""
    end

    {
      header: header_text.to_s,
      body: rendered_body,
      footer: footer_text.to_s,
      signature_name: digital_signature_name.to_s,
      signature_title: digital_signature_title.to_s
    }
  end
end
