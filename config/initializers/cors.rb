Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("API_CORS_ORIGINS", "*").split(",").map(&:strip)

    resource "/api/*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      expose: %w[Authorization Content-Type],
      max_age: 600
  end
end
