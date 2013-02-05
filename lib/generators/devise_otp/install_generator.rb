module DeviseOtp
  module Generators # :nodoc:
    # Install Generator
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Install the devise OTP authentication extension"

      def add_configs

content = <<-CONTENT

  # ==> Devise OTP Extension
  # Configure OTP extension for devise

  # How long should the user have to enter their token. To change the default, uncomment and change the below:
  #config.otp_authentication_timeout = 3.minutes

  # Change time drift settings for valid token values. To change the default, uncomment and change the below:
  #config.otp_authentication_time_drift = 3
CONTENT

        inject_into_file "config/initializers/devise.rb", content, :before => /end[ |\n|]+\Z/
      end

      def copy_locale
        copy_file "../../../config/locales/en.yml", "config/locales/devise.otp.en.yml"
      end
    end
  end
end