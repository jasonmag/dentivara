require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @admin = User.create!(name: "System Admin", email: "admin@example.com", role: :system_admin, password: "password123", password_confirmation: "password123")
    sign_in_as(@admin)
  end

  test "should get index" do
    get users_url
    assert_response :success
  end

  test "should get new" do
    get new_user_url
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count") do
      post users_url, params: { user: { email: "new_user@example.com", name: @user.name, role: @user.role } }
    end

    assert_redirected_to user_url(User.last)
  end

  test "should show user" do
    get user_url(@user)
    assert_response :success
  end

  test "should get edit" do
    get edit_user_url(@user)
    assert_response :success
  end

  test "should update user" do
    patch user_url(@user), params: { user: { email: @user.email, name: @user.name, role: @user.role } }
    assert_redirected_to user_url(@user)
  end

  test "should update user password" do
    patch user_url(@user), params: {
      user: {
        email: @user.email,
        name: @user.name,
        role: @user.role,
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
    }

    assert_redirected_to user_url(@user)
    assert @user.reload.authenticate("newpassword123")
  end

  test "should keep current password when password fields are blank" do
    @user.update!(password: "currentpassword123", password_confirmation: "currentpassword123")

    patch user_url(@user), params: {
      user: {
        email: @user.email,
        name: "Updated Name",
        role: @user.role,
        password: "",
        password_confirmation: ""
      }
    }

    assert_redirected_to user_url(@user)
    assert @user.reload.authenticate("currentpassword123")
    assert_equal "Updated Name", @user.name
  end

  test "should destroy user" do
    assert_difference("User.count", -1) do
      delete user_url(@user)
    end

    assert_redirected_to users_url
  end
  end
