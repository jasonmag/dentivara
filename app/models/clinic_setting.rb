class ClinicSetting < ApplicationRecord
  DEFAULT_TIME_ZONE = "Asia/Manila"

  validates :time_zone, presence: true
  validate :time_zone_identifier_exists

  def self.current
    first_or_create!(time_zone: DEFAULT_TIME_ZONE)
  end

  def self.current_time_zone
    current.time_zone.presence || DEFAULT_TIME_ZONE
  end

  def self.time_zone_options
    TZInfo::Timezone.all_identifiers.sort.map { |identifier| [ identifier, identifier ] }
  end

  private

  def time_zone_identifier_exists
    TZInfo::Timezone.get(time_zone)
  rescue TZInfo::InvalidTimezoneIdentifier
    errors.add(:time_zone, "is not included in the list")
  end
end
