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
        if resource.within_recovery_timeout?
          @otp_recovery_forced = true
          @recovery = true
          otp_set_flash_message(:alert, :too_many_failed_attempts, now: true)
        elsif resource.otp_by_email_enabled?
          otp_set_flash_message(:notice, :otp_by_email_code_sent, now: true)
          resource.send_email_otp_instructions if resource.otp_by_email_token_expired?
        end

        render :show
      end

      #
      # signs the resource in, if the OTP token is valid and the user has a valid challenge
      #
      def update
        if @token.blank?
          otp_set_flash_message(:alert, :token_blank, now: true)
          return render(:show)
        end

        if resource.otp_challenge_valid? && resource.validate_otp_token(@token, @recovery)
          resource.reset_failed_attempts

          sign_in(resource_name, resource)

          otp_set_trusted_device_for(resource) if params[:enable_persistence] == "true"
          otp_refresh_credentials_for(resource)
          respond_with resource, location: after_sign_in_path_for(resource)
        else
          resource.bump_failed_attempts

          message = :token_invalid
          # TODO: deduplicate code copied from #show
          if resource.within_recovery_timeout?
            @otp_recovery_forced = true
            message = :too_many_failed_attempts
          elsif resource.otp_by_email_enabled? && resource.otp_by_email_token_expired?
            message = :otp_by_email_code_expired
            resource.send_email_otp_instructions
          end

          otp_set_flash_message(:alert, message, now: true)
          render :show
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
        render :refresh
      end

      def self.controller_path
        "#{::Devise.otp_controller_path}/otp_credentials"
      end
    end
  end
end
