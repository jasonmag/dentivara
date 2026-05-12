ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # DRb-based parallelization can fail in restricted environments.
    parallelize(workers: 1)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

class ActionDispatch::IntegrationTest
  def sign_in_as(user, password: "password123")
    user.update!(password: password, password_confirmation: password)
    post login_url, params: { email: user.email, password: password }
    follow_redirect! if response.redirect?
  end

  def api_headers_for(user, token_name: "Test client")
    _access_token, raw_token = ApiAccessToken.generate!(user: user, name: token_name)
    { "Authorization" => "Bearer #{raw_token}" }
  end
end
