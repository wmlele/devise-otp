ENV["RAILS_ENV"] = "test"

require "dummy/config/environment"
require "rails/test_help"
require "capybara/rails"
require "minitest/reporters"

Minitest::Reporters.use!

# ActiveSupport::Deprecation.silenced = true

class ActionDispatch::IntegrationTest
  include Capybara::DSL
end

require "devise-otp"
