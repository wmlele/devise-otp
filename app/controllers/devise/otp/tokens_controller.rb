class Devise::Otp::TokensController < DeviseController
  include ::Devise::Controllers::Helpers

  prepend_before_action :ensure_credentials_refresh
  prepend_before_action :authenticate_scope!

  protect_from_forgery :except => [:clear_persistence, :delete_persistence]

  #
  # Displays the status of OTP authentication
  #
  def show
    if resource.nil?
      redirect_to stored_location_for(scope) || :root
    else
      render :show
    end
  end

  #
  # Updates the status of OTP authentication
  #
  def update

    enabled =  (params[resource_name][:otp_enabled] == '1')
    if (enabled ? resource.enable_otp! : resource.disable_otp!)

      otp_set_flash_message :success, :successfully_updated
    end
    render :show
  end

  #
  # Resets OTP authentication, generates new credentials, sets it to off
  #
  def destroy

    if resource.reset_otp_credentials!
      otp_set_flash_message :success, :successfully_reset_creds
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
    redirect_to :action => :show
  end


  #
  # clears persistence for the current browser
  #
  def clear_persistence
    if otp_clear_trusted_device_for(resource)
      otp_set_flash_message :success, :successfully_cleared_persistence
    end

    redirect_to :action => :show
  end


  #
  # rehash the persistence secret, thus, making all the persistence cookies invalid
  #
  def delete_persistence
    if otp_reset_persistence_for(resource)
      otp_set_flash_message :notice, :successfully_reset_persistence
    end

    redirect_to :action => :show
  end

  #
  #
  #
  def recovery
    respond_to do |format|
      format.html
      format.js
      format.text do
        send_data render_to_string(template: "devise/otp/tokens/recovery_codes.text.erb"), filename: "recovery-codes.txt"
      end
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


end
