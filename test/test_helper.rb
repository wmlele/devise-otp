ENV["RAILS_ENV"] = "test"
DEVISE_ORM = (ENV["DEVISE_ORM"] || :active_record).to_sym

$:.unshift File.dirname(__FILE__)
puts "\n==> Devise.orm = #{DEVISE_ORM.inspect}"
require "dummy/config/environment"
require "orm/#{DEVISE_ORM}"
require 'rails/test_help'
require 'capybara/rails'
require 'capybara/cuprite'
require 'minitest/reporters'

MiniTest::Reporters.use!

#I18n.load_path << File.expand_path("../support/locale/en.yml", __FILE__) if DEVISE_ORM == :mongoid

#ActiveSupport::Deprecation.silenced = true

# Use a module to not pollute the global namespace
module CapybaraHelper
  def self.register_driver(driver_name, args = [])
    opts = { headless: true, js_errors: true, window_size: [1920, 1200], browser_options: {} }
    args.each do |arg|
      opts[:browser_options][arg] = nil
    end

    Capybara.register_driver(driver_name) do |app|
      Capybara::Cuprite::Driver.new(app, opts)
    end
  end
end

# Register our own custom drivers
CapybaraHelper.register_driver(:headless_chrome, %w[disable-gpu no-sandbox disable-dev-shm-usage])

# Configure Capybara JS driver
Capybara.current_driver    = :headless_chrome
Capybara.javascript_driver = :headless_chrome

# Configure Capybara server
Capybara.run_server = true
Capybara.server     = :puma, { Silent: true }

class ActionDispatch::IntegrationTest
  include Capybara::DSL
end
