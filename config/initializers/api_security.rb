if Rails.env.in?(%w[production staging])
  if ENV["API_V1_TOKEN"].to_s.blank?
    raise "API_V1_TOKEN must be set in #{Rails.env} for /api/v1 authentication"
  end
end
