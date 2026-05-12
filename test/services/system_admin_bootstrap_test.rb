require "test_helper"

class SystemAdminBootstrapTest < ActiveSupport::TestCase
  setup do
    @previous_email = ENV["ADMIN_EMAIL"]
    @previous_password = ENV["ADMIN_PASSWORD"]
  end

  teardown do
    ENV["ADMIN_EMAIL"] = @previous_email
    ENV["ADMIN_PASSWORD"] = @previous_password
  end

  test "creates system admin when env is present" do
    ENV["ADMIN_EMAIL"] = "bootstrap-admin@example.com"
    ENV["ADMIN_PASSWORD"] = "supersecret123"

    user = SystemAdminBootstrap.from_env!

    assert user.persisted?
    assert_equal "bootstrap-admin@example.com", user.email
    assert_equal "System Admin", user.name
    assert_equal "system_admin", user.role
  end

  test "returns nil when env is missing" do
    ENV["ADMIN_EMAIL"] = ""
    ENV["ADMIN_PASSWORD"] = ""

    assert_nil SystemAdminBootstrap.from_env!
  end
end
