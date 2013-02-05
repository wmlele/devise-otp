class DeviseOtp::TokensController < DeviseController
  include Devise::Controllers::Helpers

  prepend_before_filter :authenticate_scope!
  before_filter :ensure_credentials_refresh


  #
  # Displays the status of OTP authentication
  #
  def show
   if resource.nil?
      sign_in scope, resource, :bypass => true
      redirect_to stored_location_for(scope) || :root
    else
      render :show
    end
  end

  #
  # Updates the status of OTP authentication
  #
  def update

    if resource.update_without_password(params[resource_name], :as => :otp_privileged)
      otp_set_flash_message :success, :successfully_updated
      sign_in scope, resource, :bypass => true
      render :show
    else
      render :show
    end
  end

  #
  # Resets OTP authentication, generates new credentials, sets it to off
  #
  def destroy

    if resource.reset_otp_credentials!
      otp_set_flash_message :success, :successfully_reset_creds
      sign_in scope, resource, :bypass => true
    end
    render :show
  end


  #
  # makes the current browser persistent
  #
  def get_persistence
    if otp_set_trusted_device_for(resource)
      otp_set_flash_message :success, :successfully_set_persistence
    end

    sign_in scope, resource, :bypass => true
    redirect_to :action => :show
  end


  #
  # clears persistence for the current browser
  #
  def clear_persistence
    if otp_clear_trusted_device_for(resource)
      otp_set_flash_message :success, :successfully_cleared_persistence
    end

    sign_in scope, resource, :bypass => true
    redirect_to :action => :show
  end


  #
  # rehash the persistence secret, thus, making all the persistence cookies invalid
  #
  def delete_persistence
    if otp_reset_persistence_for(resource)
      otp_set_flash_message :notice, :successfully_reset_persistence
    end

    sign_in scope, resource, :bypass => true
    redirect_to :action => :show
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

  def authenticate_scope!
    send(:"authenticate_#{resource_name}!", :force => true)
    self.resource = send("current_#{resource_name}")
  end
end