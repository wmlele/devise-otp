module DeviseOtpAuthenticatable
  class Engine < ::Rails::Engine

    ActiveSupport.on_load(:action_controller) do
      include DeviseOtpAuthenticatable::Controllers::UrlHelpers
      include DeviseOtpAuthenticatable::Controllers::Helpers
    end
    ActiveSupport.on_load(:action_view) do
      include DeviseOtpAuthenticatable::Controllers::UrlHelpers
      include DeviseOtpAuthenticatable::Controllers::Helpers
    end

    # We use to_prepare instead of after_initialize here because Devise is a Rails engine;
    config.to_prepare do
      DeviseOtpAuthenticatable::Hooks.apply
    end

    # extend mapping with after_initialize because is not reloaded
    config.after_initialize do
      ::Devise::Mapping.send :include, ::DeviseOtpAuthenticatable::Mapping
    end
  end
end
