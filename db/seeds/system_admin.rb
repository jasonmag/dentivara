# frozen_string_literal: true

require "dotenv/load" if Rails.env.local?

user = SystemAdminBootstrap.from_env!

if user.present?
  puts "System admin ready: #{user.email}"
else
  abort "ADMIN_EMAIL and ADMIN_PASSWORD are required. ADMIN_PASSWORD must be at least 8 characters."
end
