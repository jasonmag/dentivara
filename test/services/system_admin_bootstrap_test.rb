require "test_helper"

class SystemAdminBootstrapTest < ActiveSupport::TestCase
  setup do
    @previous_email = ENV["ADMIN_EMAIL"]
    @previous_password = ENV["ADMIN_PASSWORD"]
    @previous_name = ENV["ADMIN_NAME"]
  end

  teardown do
    ENV["ADMIN_EMAIL"] = @previous_email
    ENV["ADMIN_PASSWORD"] = @previous_password
    ENV["ADMIN_NAME"] = @previous_name
  end

  test "creates system admin when env is present" do
    ENV["ADMIN_EMAIL"] = "bootstrap-admin@example.com"
    ENV["ADMIN_PASSWORD"] = "supersecret123"
    ENV["ADMIN_NAME"] = "Bootstrap Admin"

    user = SystemAdminBootstrap.from_env!

    assert user.persisted?
    assert_equal "bootstrap-admin@example.com", user.email
    assert_equal "Bootstrap Admin", user.name
    assert_equal "system_admin", user.role
  end

  test "returns nil when env is missing" do
    ENV["ADMIN_EMAIL"] = ""
    ENV["ADMIN_PASSWORD"] = ""

    assert_nil SystemAdminBootstrap.from_env!
  end
end
