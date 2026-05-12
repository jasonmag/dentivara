class IntraoralScan < ApplicationRecord
  include Auditable

  SCAN_TYPES = %w[intraoral_scan upper_arch lower_arch bite_scan occlusion_scan restoration_scan orthodontic_scan].freeze
  VIEWABLE_3D_EXTENSIONS = %w[stl ply obj].freeze
  ALLOWED_EXTENSIONS = (VIEWABLE_3D_EXTENSIONS + %w[zip pdf jpg jpeg png]).freeze
  ALLOWED_CONTENT_TYPES = %w[
    application/octet-stream
    application/sla
    model/stl
    model/x.stl-ascii
    model/x.stl-binary
    model/obj
    application/zip
    application/pdf
    image/jpeg
    image/png
    text/plain
  ].freeze

  belongs_to :patient
  belongs_to :user
  has_one_attached :scan_file

  validates :captured_on, presence: true
  validates :scan_type, inclusion: { in: SCAN_TYPES }
  validate :scan_file_attached
  validate :scan_file_is_supported
  validate :scan_file_size

  scope :recent_first, -> { order(captured_on: :desc, created_at: :desc) }

  def file_extension
    scan_file.filename.extension_without_delimiter.to_s.downcase if scan_file.attached?
  end

  def viewable_3d?
    file_extension.in?(VIEWABLE_3D_EXTENSIONS)
  end

  private

  def scan_file_attached
    return if scan_file.attached?

    errors.add(:scan_file, "must be uploaded")
  end

  def scan_file_is_supported
    return unless scan_file.attached?
    return if file_extension.in?(ALLOWED_EXTENSIONS) && scan_file.content_type.in?(ALLOWED_CONTENT_TYPES)

    errors.add(:scan_file, "must be STL, PLY, OBJ, ZIP, PDF, JPG, or PNG")
  end

  def scan_file_size
    return unless scan_file.attached?
    return if scan_file.byte_size <= 250.megabytes

    errors.add(:scan_file, "must be 250MB or less")
  end
end
