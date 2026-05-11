if Rails.env.in?(%w[production staging]) && ENV["API_V1_TOKEN"].present? && ENV["API_V1_LEGACY_TOKEN_ENABLED"] == "true"
  Rails.logger.warn("Legacy API_V1_TOKEN auth is enabled. Prefer user-scoped ApiAccessToken records.")
end
