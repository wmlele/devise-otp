ENV["RAILS_ENV"] = "test"
DEVISE_ORM = (ENV["DEVISE_ORM"] || :active_record).to_sym

puts "\n==> Devise.orm = #{DEVISE_ORM.inspect}"
require "dummy/config/environment"
require "orm/#{DEVISE_ORM}"
require "rails/test_help"
require "capybara/rails"
require "capybara/cuprite"
require "minitest/reporters"

Minitest::Reporters.use!

# I18n.load_path << File.expand_path("../support/locale/en.yml", __FILE__) if DEVISE_ORM == :mongoid

# ActiveSupport::Deprecation.silenced = true

# Use a module to not pollute the global namespace
module CapybaraHelper
  def self.register_driver(driver_name, args = [])
    opts = {headless: true, js_errors: true, window_size: [1920, 1200], browser_options: {}}
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
Capybara.current_driver = :headless_chrome
Capybara.javascript_driver = :headless_chrome

# Configure Capybara server
Capybara.run_server = true
Capybara.server = :puma, {Silent: true}

class ActionDispatch::IntegrationTest
  include Capybara::DSL

  # What capybara calls a "page" in its DSL is actually a Capybara::Session
  # and doesn't know about the *command* method that allows us to play with
  # the Chrome API.
  # See: https://rubydoc.info/github/jnicklas/capybara/master/Capybara/Session
  #
  # To enable downloads we need to do it on the browser's page object, so fetch it
  # from this long method chain.
  # See: https://github.com/rubycdp/ferrum/blob/master/lib/ferrum/page.rb
  def enable_chrome_headless_downloads(session, directory)
    page = session.driver.browser.page
    page.command("Page.setDownloadBehavior", behavior: "allow", downloadPath: directory)
  end
end

# From https://collectiveidea.com/blog/archives/2012/01/27/testing-file-downloads-with-capybara-and-chromedriver
module DownloadHelper
  extend self

  TIMEOUT = 10

  def downloads
    Dir["/tmp/devise-otp/*"]
  end

  def wait_for_download(count: 1)
    yield if block_given?

    Timeout.timeout(TIMEOUT) do
      sleep 0.2 until downloaded?(count)
    end
  end

  def downloaded?(count)
    !downloading? && downloads.size == count
  end

  def downloading?
    downloads.grep(/\.crdownload$/).any?
  end

  def clear_downloads
    FileUtils.rm_f(downloads)
  end
end

require "devise-otp"
