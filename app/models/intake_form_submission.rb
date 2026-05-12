class IntakeFormSubmission < ApplicationRecord
  belongs_to :patient, optional: true
  belongs_to :submitted_by_user, class_name: "User", optional: true

  SOURCES = %w[online walk_in concierge].freeze
  STATUSES = %w[submitted reviewed archived].freeze

  validates :source, inclusion: { in: SOURCES }
  validates :status, inclusion: { in: STATUSES }
end
