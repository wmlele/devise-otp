ENV["RAILS_ENV"] = "test"
DEVISE_ORM = (ENV["DEVISE_ORM"] || :active_record).to_sym

puts "\n==> Devise.orm = #{DEVISE_ORM.inspect}"
require "dummy/config/environment"
require "orm/#{DEVISE_ORM}"
require "rails/test_help"
require "capybara/rails"
require "minitest/reporters"

Minitest::Reporters.use!

# I18n.load_path << File.expand_path("../support/locale/en.yml", __FILE__) if DEVISE_ORM == :mongoid

# ActiveSupport::Deprecation.silenced = true

class ActionDispatch::IntegrationTest
  include Capybara::DSL
end

require "devise-otp"
