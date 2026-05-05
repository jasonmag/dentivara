class ComplianceController < ApplicationController
  before_action -> { require_roles(:clinic_owner, :system_admin) }

  def show
    @total_patients = Patient.count
    @consented_patients = Patient.joins(:patient_consents).distinct.count
    @consent_coverage = if @total_patients.zero?
      100
    else
      ((@consented_patients.to_f / @total_patients) * 100).round(1)
    end

    @recent_access_logs = AccessLog.includes(:user).order(created_at: :desc).limit(50)
    @recent_audit_logs = AuditLog.includes(:user).order(created_at: :desc).limit(50)

    @audit_chain = audit_chain_report(@recent_audit_logs)
  end

  private

  def audit_chain_report(logs)
    previous = nil
    broken = []

    logs.sort_by(&:id).each do |log|
      expected_previous = previous.to_s
      broken << log if log.previous_hash.to_s != expected_previous
      previous = log.event_hash
    end

    {
      total_checked: logs.size,
      broken_count: broken.size,
      broken_ids: broken.map(&:id)
    }
  end
end
