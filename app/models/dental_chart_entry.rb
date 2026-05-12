class DentalChartEntry < ApplicationRecord
  ENTRY_TYPES = %w[exam diagnosis procedure periodontal restorative notes].freeze
  SURFACE_STATUSES = %w[caries filling missing crown root_canal watch].freeze

  belongs_to :patient
  belongs_to :user
  has_one_attached :chart_image

  validates :entry_type, inclusion: { in: ENTRY_TYPES }
  validates :recorded_on, presence: true
  validate :notes_or_image_present
  validate :chart_image_is_valid
  validate :surface_marks_shape

  private

  def notes_or_image_present
    return if notes.present? || chart_image.attached?

    errors.add(:base, "Add notes or upload a chart image.")
  end

  def chart_image_is_valid
    return unless chart_image.attached?

    if !chart_image.content_type.in?(%w[image/png image/jpeg image/jpg image/webp])
      errors.add(:chart_image, "must be a PNG, JPG, or WEBP image.")
    end
  end

  def surface_marks_shape
    return if surface_marks.is_a?(Array) && surface_marks.all? { |item| item.is_a?(Hash) }

    errors.add(:surface_marks, "must be a list of tooth surface marks.")
  end
end
