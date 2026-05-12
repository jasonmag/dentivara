Rails.application.configure do
  config.active_record.encryption.primary_key = ENV.fetch("AR_ENCRYPTION_PRIMARY_KEY", "d6a4e8af5f57ad4ce2a1c8272ef8b48c")
  config.active_record.encryption.deterministic_key = ENV.fetch("AR_ENCRYPTION_DETERMINISTIC_KEY", "3bc8f17f5fda1ee2e6b3f8d5ef429f79")
  config.active_record.encryption.key_derivation_salt = ENV.fetch("AR_ENCRYPTION_KEY_DERIVATION_SALT", "c6124d497cff9f17d89d8a5f8a4e8f70")
end
