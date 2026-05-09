namespace :admin do
  desc "Create or update default system admin from ADMIN_EMAIL and ADMIN_PASSWORD"
  task bootstrap: :environment do
    user = SystemAdminBootstrap.from_env!
    if user.present?
      puts "System admin ready: #{user.email}"
    else
      puts "Skipped admin bootstrap (set ADMIN_EMAIL and ADMIN_PASSWORD with at least 8 chars)."
    end
  end
end
