class ClinicSetting < ApplicationRecord
  include TenantScoped

  DEFAULT_TIME_ZONE = "Asia/Manila"
  DEFAULT_CURRENCY = "USD"
  DEFAULT_CURRENCY_LOCALE = "en-US"
  CURRENCY_OPTIONS = {
    "USD" => { label: "USD ($) - United States Dollar", symbol: "$", locale: "en-US", delimiter: ",", separator: "." },
    "PHP" => { label: "PHP (₱) - Philippine Peso", symbol: "₱", locale: "en-PH", delimiter: ",", separator: "." },
    "EUR" => { label: "EUR (€) - Euro", symbol: "€", locale: "de-DE", delimiter: ".", separator: "," },
    "GBP" => { label: "GBP (£) - British Pound", symbol: "£", locale: "en-GB", delimiter: ",", separator: "." },
    "SGD" => { label: "SGD (S$) - Singapore Dollar", symbol: "S$", locale: "en-SG", delimiter: ",", separator: "." },
    "AUD" => { label: "AUD (A$) - Australian Dollar", symbol: "A$", locale: "en-AU", delimiter: ",", separator: "." }
  }.freeze

  validates :time_zone, :currency_code, :currency_locale, presence: true
  validates :currency_code, inclusion: { in: CURRENCY_OPTIONS.keys }
  validates :queue_eta_minutes_default, :queue_eta_minutes_scheduled, :queue_eta_minutes_walk_in,
            :queue_eta_minutes_emergency, :queue_eta_minutes_priority,
            numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 180 }
  validate :time_zone_identifier_exists
  before_validation :apply_currency_locale

  def self.current
    clinic = Current.clinic || Clinic.default
    find_or_create_by!(clinic: clinic) do |setting|
      setting.time_zone = DEFAULT_TIME_ZONE
      setting.currency_code = DEFAULT_CURRENCY
      setting.currency_locale = DEFAULT_CURRENCY_LOCALE
    end
  end

  def self.platform_default
    first_or_create!(
      time_zone: DEFAULT_TIME_ZONE,
      currency_code: DEFAULT_CURRENCY,
      currency_locale: DEFAULT_CURRENCY_LOCALE
    )
  end

  def self.current_time_zone
    current.time_zone.presence || DEFAULT_TIME_ZONE
  end

  def self.current_currency_code
    current.currency_code.presence || DEFAULT_CURRENCY
  end

  def self.currency_options_for_select
    CURRENCY_OPTIONS.map { |code, config| [ config.fetch(:label), code ] }
  end

  def currency_config
    CURRENCY_OPTIONS.fetch(currency_code, CURRENCY_OPTIONS.fetch(DEFAULT_CURRENCY))
  end

  def self.time_zone_options
    TZInfo::Timezone.all_identifiers.sort.map { |identifier| [ identifier, identifier ] }
  end

  def queue_eta_minutes_for(queue_type)
    case queue_type.to_s
    when "scheduled"
      queue_eta_minutes_scheduled
    when "walk_in"
      queue_eta_minutes_walk_in
    when "emergency"
      queue_eta_minutes_emergency
    when "priority"
      queue_eta_minutes_priority
    else
      queue_eta_minutes_default
    end
  end

  private

  def apply_currency_locale
    self.currency_locale = currency_config.fetch(:locale)
  end

  def time_zone_identifier_exists
    TZInfo::Timezone.get(time_zone)
  rescue TZInfo::InvalidTimezoneIdentifier
    errors.add(:time_zone, "is not included in the list")
  end
end
