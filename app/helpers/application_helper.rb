module ApplicationHelper
  def clinic_currency_config
    @clinic_currency_config ||= ClinicSetting.current.currency_config
  end

  def clinic_currency_code
    ClinicSetting.current_currency_code
  end

  def clinic_currency_symbol
    clinic_currency_config.fetch(:symbol)
  end

  def clinic_number_to_currency(amount, precision: 2)
    config = clinic_currency_config

    number_to_currency(
      amount,
      unit: config.fetch(:symbol),
      separator: config.fetch(:separator),
      delimiter: config.fetch(:delimiter),
      precision: precision,
      format: "%u%n"
    )
  end
end
