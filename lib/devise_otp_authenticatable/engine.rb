module DeviseOtpAuthenticatable
  class Engine < ::Rails::Engine
    config.devise_otp = ActiveSupport::OrderedOptions.new
    config.devise_otp.precompile_assets = true

    # We use to_prepare instead of after_initialize here because Devise is a Rails engine;
    config.to_prepare do
      DeviseOtpAuthenticatable::Hooks.apply
    end

    initializer "devise-otp", group: :all do |app|
      ActiveSupport.on_load(:devise_controller) do
        include DeviseOtpAuthenticatable::Controllers::UrlHelpers
        include DeviseOtpAuthenticatable::Controllers::Helpers
      end

      ActiveSupport.on_load(:action_view) do
        include DeviseOtpAuthenticatable::Controllers::UrlHelpers
        include DeviseOtpAuthenticatable::Controllers::Helpers
      end

      # See: https://guides.rubyonrails.org/engines.html#separate-assets-and-precompiling
      # check if Rails api mode
      if app.config.respond_to?(:assets) && app.config.devise_otp.precompile_assets
        if defined?(Sprockets) && Sprockets::VERSION >= "4"
          app.config.assets.precompile << "devise-otp.js"
        else
          # use a proc instead of a string
          app.config.assets.precompile << proc { |path| path == "devise-otp.js" }
        end
      end
    end
  end
end
