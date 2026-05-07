class RolePermissionsController < ApplicationController
  before_action -> { require_roles(:system_admin) }

  def new
    @selected_role = selected_role
    @role_permission = role_permission_for(@selected_role)
  end

  def create
    @selected_role = role_permission_params[:role].presence || "receptionist"
    @role_permission = role_permission_for(@selected_role)
    @role_permission.assign_attributes(role_permission_params.except(:role))

    if @role_permission.save
      redirect_to new_role_permission_path(role: @role_permission.role), notice: "Role permissions saved."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def selected_role
    role = params[:role].to_s
    User.roles.key?(role) ? role : "receptionist"
  end

  def role_permission_for(role_name)
    RolePermission.find_or_initialize_by(role: role_name)
  end

  def role_permission_params
    params.require(:role_permission).permit(:role, permissions: {})
  end
end
