class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  helper_method :current_user

  private

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = if session[:user_id].present?
      User.find_by(id: session[:user_id])
    else
      User.order(:id).first
    end
  end

  def require_roles(*roles)
    return if current_user.present? && roles.map(&:to_s).include?(current_user.role)

    redirect_to root_path, alert: "You are not authorized for this action."
  end
end
