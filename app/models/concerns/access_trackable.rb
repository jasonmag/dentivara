module AccessTrackable
  extend ActiveSupport::Concern

  private

  def track_access!(resource:, action: "view")
    AccessLog.create!(
      user: Current.user,
      resource_type: resource.class.name,
      resource_id: resource.id,
      action: action,
      ip_address: request.remote_ip,
      user_agent: request.user_agent.to_s.first(255)
    )
  rescue StandardError
    nil
  end
end
