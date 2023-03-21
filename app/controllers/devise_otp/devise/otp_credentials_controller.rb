module DeviseOtp
  module Devise
    class OtpCredentialsController < DeviseController
      helper_method :new_session_path

      prepend_before_action :authenticate_scope!, only: [:get_refresh, :set_refresh]
      prepend_before_action :require_no_authentication, only: [:show, :update]

      #
      # show a request for the OTP token
      #
      def show
        @challenge = params[:challenge]
        @recovery = (params[:recovery] == "true") && recovery_enabled?

        if @challenge.nil?
          redirect_to :root
        else
          self.resource = resource_class.find_valid_otp_challenge(@challenge)
          if resource.nil?
            redirect_to :root
          elsif @recovery
            @recovery_count = resource.otp_recovery_counter
            render :show
          else
            render :show
          end
        end
      end

      #
      # signs the resource in, if the OTP token is valid and the user has a valid challenge
      #
      def update
        resource = resource_class.find_valid_otp_challenge(params[resource_name][:challenge])
        recovery = (params[resource_name][:recovery] == "true") && recovery_enabled?
        token = params[resource_name][:token]

        if token.blank?
          otp_set_flash_message(:alert, :token_blank)
          redirect_to otp_credential_path_for(resource_name, challenge: params[resource_name][:challenge],
                                              recovery: recovery)
        elsif resource.nil?
          otp_set_flash_message(:alert, :otp_session_invalid)
          redirect_to new_session_path(resource_name)
        elsif resource.otp_challenge_valid? && resource.validate_otp_token(params[resource_name][:token], recovery)
          sign_in(resource_name, resource)

          otp_set_trusted_device_for(resource) if (params[:enable_persistence] == 'true') || (params[:enable_persistence] == 'on') || (params[:enable_persistence] == 'checked')
          otp_refresh_credentials_for(resource)
          respond_with resource, :location => after_sign_in_path_for(resource)
        else
          otp_set_flash_message :alert, :token_invalid
          redirect_to new_session_path(resource_name)
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

      def done_valid_refresh
        otp_refresh_credentials_for(resource)
        otp_set_flash_message :success, :valid_refresh if is_navigational_format?

        respond_with resource, location: otp_fetch_refresh_return_url
      end

      def failed_refresh
        otp_set_flash_message :alert, :invalid_refresh
        render :refresh
      end

      def self.controller_path
        "#{::Devise.otp_controller_path}/otp_credentials"
      end
    end
  end
end

