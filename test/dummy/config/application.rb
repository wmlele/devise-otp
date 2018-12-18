require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_storage/engine"
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"

begin
  require "#{DEVISE_ORM}/railtie"
rescue LoadError
end
PARENT_MODEL_CLASS = DEVISE_ORM == :active_record ? ActiveRecord::Base : Object

require "devise"
require "devise-otp"

Bundler.require
Bundler.require(:default, DEVISE_ORM) if defined?(Bundler)
Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end

