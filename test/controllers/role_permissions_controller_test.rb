require "test_helper"

class RolePermissionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(
      name: "System Admin",
      email: "system-admin@example.com",
      role: :system_admin,
      password: "password123",
      password_confirmation: "password123"
    )
    sign_in_as(@admin)
  end

  test "should get new" do
    get new_role_permission_url
    assert_response :success
  end

  test "should create or update role permissions" do
    assert_difference("RolePermission.count", 1) do
      post role_permission_url, params: {
        role_permission: {
          role: "dentist",
          permissions: {
            patients: { view: "1", create: "0", update: "0", destroy: "0" }
          }
        }
      }
    end

    assert_redirected_to new_role_permission_url(role: "dentist")
    assert_not RolePermission.find_by(role: :dentist).permission_matrix.dig("patients", "create")
  end
end
