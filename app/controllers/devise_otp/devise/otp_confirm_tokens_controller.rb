module DeviseOtp
  module Devise
    class OtpConfirmTokensController < DeviseController
      include ::Devise::Controllers::Helpers

      prepend_before_action :ensure_credentials_refresh
      prepend_before_action :authenticate_scope!

      #
      # Displays the OTP
      #
      def show
        if resource.nil?
          redirect_to stored_location_for(scope) || :root
        else
          render "devise/otp_confirm_tokens/show"
        end
      end

      #
      # Confirms the OTP if valid
      #
      def update
        if resource.valid_otp_token?(params[:otp_token])
          resource.confirm_otp!
          otp_set_flash_message :success, :successfully_updated
          redirect_to otp_credential_path_for(resource)
        else
          otp_set_flash_message :failure, :otp_token_does_not_match
          render "devise/otp_confirm_tokens/show"
        end
      end

      private

      def ensure_credentials_refresh
        ensure_resource!

        if needs_credentials_refresh?(resource)
          otp_set_flash_message :notice, :need_to_refresh_credentials
          redirect_to refresh_otp_credential_path_for(resource)
        end
      end

      def scope
        resource_name.to_sym
      end

      def self.controller_path
        "#{::Devise.otp_controller_path}/confirm_otp_tokens"
      end
    end
  end
end
