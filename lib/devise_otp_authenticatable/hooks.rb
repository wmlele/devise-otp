module DeviseOtpAuthenticatable
  module Hooks

    autoload :Sessions, 'devise_otp_authenticatable/hooks/sessions.rb'

    class << self
      def apply
        Devise::SessionsController.send(:prepend, Hooks::Sessions)
      end
    end

  end
end
