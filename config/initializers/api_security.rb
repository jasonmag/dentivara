if Rails.env.in?(%w[production staging])
  running_assets_precompile =
    defined?(Rake) &&
    Rake.respond_to?(:application) &&
    Rake.application.top_level_tasks.any? { |task| task.start_with?("assets:precompile") }

  if ENV["API_V1_TOKEN"].to_s.blank? && !running_assets_precompile
    raise "API_V1_TOKEN must be set in #{Rails.env} for /api/v1 authentication"
  end
end
