module DeviseOtpAuthenticatable

  module Mapping

    def default_controllers(options)
      options[:controllers] ||= {}

      options[:controllers][:otp_tokens]      ||= "tokens"
      options[:controllers][:otp_credentials] ||= "credentials"

      super(options)
    end
  end
end

Devise::Mapping.prepend(DeviseOtpAuthenticatable::Mapping)
