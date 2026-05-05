namespace :data_retention do
  desc "Cleanup old access/audit logs based on retention windows"
  task cleanup: :environment do
    access_days = ENV.fetch("ACCESS_LOG_RETENTION_DAYS", 365).to_i
    audit_days = ENV.fetch("AUDIT_LOG_RETENTION_DAYS", 2555).to_i # ~7 years

    access_deleted = AccessLog.where("created_at < ?", access_days.days.ago).delete_all
    audit_deleted = AuditLog.where("created_at < ?", audit_days.days.ago).delete_all

    puts "Deleted #{access_deleted} access logs older than #{access_days} days"
    puts "Deleted #{audit_deleted} audit logs older than #{audit_days} days"
  end
end
