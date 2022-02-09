module DeviseOtpAuthenticatable

  module Mapping

    def self.included(base)
      base.alias_method :default_controllers_without_otp, :default_controllers
      base.alias_method :default_controller, :default_controllers_with_otp
    end

    private
    def default_controllers_with_otp(options)
      options[:controllers] ||= {}

      options[:controllers][:otp_tokens]      ||= "tokens"
      options[:controllers][:otp_credentials] ||= "credentials"

      default_controllers_without_otp(options)
    end
  end
end