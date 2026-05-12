require "test_helper"

class ApiAccessTokenTest < ActiveSupport::TestCase
  Request = Struct.new(:remote_ip, :user_agent)

  test "touch usage skips repeated writes within the throttle window" do
    access_token, = ApiAccessToken.generate!(user: users(:one), name: "Throttle test")
    request = Request.new("127.0.0.1", "Test browser")

    access_token.touch_usage!(request)
    first_updated_at = access_token.reload.updated_at

    travel 1.minute do
      access_token.touch_usage!(request)
    end

    assert_equal first_updated_at.to_i, access_token.reload.updated_at.to_i
  end

  test "touch usage updates after the throttle window" do
    access_token, = ApiAccessToken.generate!(user: users(:one), name: "Throttle expiry test")
    request = Request.new("127.0.0.1", "Test browser")

    access_token.touch_usage!(request)
    first_updated_at = access_token.reload.updated_at

    travel 6.minutes do
      access_token.touch_usage!(request)
    end

    assert_operator access_token.reload.updated_at, :>, first_updated_at
  end
end
