class AuditLogsController < ApplicationController
  before_action -> { require_permission!(:audit_logs, :view) }

  def index
    @audit_logs = AuditLog.includes(:user).order(created_at: :desc).limit(500)
    respond_to do |format|
      format.html
      format.csv do
        send_data to_csv(@audit_logs), filename: "audit_logs_#{Date.current}.csv"
      end
    end
  end

  private

  def to_csv(logs)
    CSV.generate(headers: true) do |csv|
      csv << %w[id timestamp user action resource resource_id event_hash previous_hash changeset]
      logs.each do |log|
        csv << [
          log.id,
          log.created_at.iso8601,
          log.user&.email,
          log.action,
          log.auditable_type,
          log.auditable_id,
          log.event_hash,
          log.previous_hash,
          log.changeset.to_json
        ]
      end
    end
  end
end
