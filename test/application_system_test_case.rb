require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Keep system tests runnable in restricted/offline environments.
  driven_by :rack_test
end
