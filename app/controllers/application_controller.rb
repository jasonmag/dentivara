class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  helper_method :current_user
  helper_method :can_access_feature?
  before_action :require_login
  before_action :set_current_user

  private

  def set_current_user
    Current.user = current_user
  end

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = User.find_by(id: session[:user_id]) if session[:user_id].present?
  end

  def require_login
    return if current_user.present?

    redirect_to login_path, alert: "Please sign in to continue."
  end

  def require_roles(*roles)
    return if current_user.present? && roles.map(&:to_s).include?(current_user.role)

    redirect_to root_path, alert: "You are not authorized for this action."
  end

  def require_permission!(feature, action = :view)
    return if can_access_feature?(feature, action)

    redirect_to root_path, alert: "You are not authorized for this action."
  end

  def can_access_feature?(feature, action = :view)
    current_user&.can_access?(feature, action) || false
  end
end
