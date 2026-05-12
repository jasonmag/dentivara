class PatientConsent < ApplicationRecord
  include Auditable

  CONSENT_TYPES = %w[data_privacy treatment financial communication].freeze

  belongs_to :patient
  belongs_to :user

  validates :document_version, :consented_at, presence: true
  validates :consent_type, inclusion: { in: CONSENT_TYPES }
end
