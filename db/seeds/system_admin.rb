# frozen_string_literal: true

user = SystemAdminBootstrap.from_env!

if user.present?
  puts "System admin ready: #{user.email}"
else
  abort "ADMIN_EMAIL and ADMIN_PASSWORD are required. ADMIN_PASSWORD must be at least 8 characters."
end
