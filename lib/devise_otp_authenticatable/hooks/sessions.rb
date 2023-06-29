module DeviseOtpAuthenticatable::Hooks
  module Sessions
    extend ActiveSupport::Concern
    include DeviseOtpAuthenticatable::Controllers::UrlHelpers

    included do
      alias_method :create, :create_with_otp
    end

    #
    # replaces Devise::SessionsController#create
    #
    def create_with_otp
      resource = warden.authenticate!(auth_options)

      devise_stored_location = stored_location_for(resource) # Grab the current stored location before it gets lost by warden.logout
      store_location_for(resource, devise_stored_location) # Restore it since #stored_location_for removes it

      otp_refresh_credentials_for(resource)

      yield resource if block_given?
      if otp_challenge_required_on?(resource)
        challenge = resource.generate_otp_challenge!
        warden.logout
        store_location_for(resource, devise_stored_location) # restore the stored location
        respond_with resource, location: otp_credential_path_for(resource, {challenge: challenge})
      elsif otp_mandatory_on?(resource) # if mandatory, log in user but send him to the must activate otp
        #set_flash_message(:notice, :signed_in_but_otp) if is_navigational_format?
        sign_in(resource_name, resource)
        respond_with resource, location: otp_token_path_for(resource)
      else
        sign_in(resource_name, resource)
        respond_with resource, location: after_sign_in_path_for(resource)
      end
    end

    private

    #
    # resource should be challenged for otp
    #
    def otp_challenge_required_on?(resource)
      return false unless resource.respond_to?(:otp_enabled) && resource.respond_to?(:otp_auth_secret)

      resource.otp_enabled && !is_otp_trusted_browser_for?(resource)
    end

    #
    # the resource -should- have otp turned on, but it isn't
    #
    def otp_mandatory_on?(resource)
      return true if resource.class.otp_mandatory && !resource.otp_enabled
      return false unless resource.respond_to?(:otp_mandatory)
      resource.otp_mandatory && !resource.otp_enabled
    end
  end
end
