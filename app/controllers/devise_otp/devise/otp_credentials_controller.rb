module DeviseOtp
  module Devise
    class OtpCredentialsController < DeviseController
      helper_method :new_session_path

      prepend_before_action :authenticate_scope!, only: [:get_refresh, :set_refresh]
      prepend_before_action :require_no_authentication, only: [:show, :update]
      before_action :set_challenge, only: [:show, :update]
      before_action :set_recovery, only: [:show, :update]
      before_action :set_resource, only: [:show, :update]
      before_action :set_token, only: [:update]
      before_action :skip_challenge_if_trusted_browser, only: [:show, :update]

      #
      # show a request for the OTP token
      #
      def show
        if @recovery
          @recovery_count = resource.otp_recovery_counter
        end

        render :show
      end

      #
      # signs the resource in, if the OTP token is valid and the user has a valid challenge
      #
      def update
        if resource.otp_challenge_valid? && resource.valid_for_authentication? && resource.validate_otp_token(@token, @recovery)
          sign_in(resource_name, resource)

          otp_set_trusted_device_for(resource) if params[:enable_persistence] == "true"
          otp_refresh_credentials_for(resource)
          respond_with resource, location: after_sign_in_path_for(resource)
        else
          # Increment failed attempts and/or lock account.
          #
          # The valid_for_authentication? method must be executed a second time
          # with "false" as the block here, to increment the failed attempts and/or
          # lock the account, since we are not passing whether the password was
          # entered correctly or not above (as the DatabaseAuthenticatable strategy
          # does when executing the validate method from the Authenticatable strategy).
          resource.valid_for_authentication? { false }

          kind = (@token.blank? ? :token_blank : :token_invalid)
          otp_set_flash_message :alert, kind, :now => true
          render :show, status: :unprocessable_entity
        end
      end

      #
      # displays the request for a credentials refresh
      #
      def get_refresh
        ensure_resource!
        render :refresh
      end

      #
      # lets the user through is the refresh is valid
      #
      def set_refresh
        ensure_resource!

        if resource.valid_password?(params[resource_name][:refresh_password])
          done_valid_refresh
        else
          failed_refresh
        end
      end

      private

      def set_challenge
        @challenge = params[:challenge]

        unless @challenge.present?
          redirect_to :root
        end
      end

      def set_recovery
        @recovery = (recovery_enabled? && params[:recovery] == "true")
      end

      def set_resource
        self.resource = resource_class.find_valid_otp_challenge(@challenge)

        unless resource.present?
          otp_set_flash_message(:alert, :otp_session_invalid)
          redirect_to new_session_path(resource_name)
        end
      end

      def set_token
        @token = params[:token]
      end

      def skip_challenge_if_trusted_browser
        if is_otp_trusted_browser_for?(resource)
          sign_in(resource_name, resource)
          otp_refresh_credentials_for(resource)
          redirect_to after_sign_in_path_for(resource)
        end
      end

      def done_valid_refresh
        otp_refresh_credentials_for(resource)
        respond_with resource, location: otp_fetch_refresh_return_url
      end

      def failed_refresh
        otp_set_flash_message :alert, :invalid_refresh, :now => true
        render :refresh, status: :unprocessable_entity
      end

      def self.controller_path
        "#{::Devise.otp_controller_path}/otp_credentials"
      end
    end
  end
end
