module DeviseOtp
  module Devise
    class OtpPersistenceController < DeviseController
      include ::Devise::Controllers::Helpers

      prepend_before_action :ensure_credentials_refresh
      prepend_before_action :authenticate_scope!

      #
      # makes the current browser persistent
      #
      def create
        if otp_set_trusted_device_for(resource)
          otp_set_flash_message :success, :successfully_set_persistence
        end

        redirect_to otp_token_path_for(resource)
      end

      #
      # clears persistence for the current browser
      #
      def destroy
        if otp_clear_trusted_device_for(resource)
          otp_set_flash_message :success, :successfully_cleared_persistence
        end

        redirect_to otp_token_path_for(resource)
      end

      #
      # rehash the persistence secret, thus, making all the persistence cookies invalid
      #
      def reset
        if otp_reset_persistence_for(resource)
          otp_set_flash_message :notice, :successfully_reset_persistence
        end

        redirect_to otp_token_path_for(resource)
      end

      private

      def ensure_credentials_refresh
        ensure_resource!

        if needs_credentials_refresh?(resource)
          redirect_to refresh_otp_credential_path_for(resource)
        end
      end
    end
  end
end
