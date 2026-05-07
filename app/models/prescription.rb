class Prescription < ApplicationRecord
  STATUSES = %w[draft finalized signed].freeze

  belongs_to :patient
  belongs_to :document_template, optional: true
  belongs_to :drafted_by_user, class_name: "User"
  belongs_to :signed_by_user, class_name: "User", optional: true
  has_one_attached :signature_image

  validates :status, inclusion: { in: STATUSES }
  validates :issued_on, :body, presence: true

  scope :recent_first, -> { order(issued_on: :desc, updated_at: :desc) }

  def can_finalize?
    draft?
  end

  def can_sign?
    finalized?
  end

  def draft?
    status == "draft"
  end

  def finalized?
    status == "finalized"
  end

  def signed?
    status == "signed"
  end
end
