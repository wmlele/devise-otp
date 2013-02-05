class DeviseOtp::CredentialsController < DeviseController
  helper_method :new_session_path

  prepend_before_filter :authenticate_scope!, :only => [:get_refresh, :set_refresh]
  prepend_before_filter :require_no_authentication, :only => [ :show, :update ]

  #
  # show a request for the OTP token
  #
  def show
    @challenge = params[:challenge]

    if @challenge.nil?
      redirect_to :root
    else
      render :show
    end
  end

  #
  # signs the resource in, if the OTP token is valid and the user has a valid challege
  #
  def update
    resource = resource_class.find_valid_otp_challenge(params[resource_name][:challenge])

    if resource.nil?
      set_flash_message(:alert, :otp_session_invalid)
      redirect_to new_session_path(resource_name)
    else
      if resource.otp_challenge_valid? && resource.validate_otp_token(params[resource_name][:token].to_i)
        set_flash_message(:success, :signed_in) if is_navigational_format?
        sign_in(resource_name, resource)

        otp_refresh_credentials_for(resource)
        respond_with resource, :location => after_sign_in_path_for(resource)
      else
        otp_set_flash_message :alert, :token_invalid
        redirect_to new_session_path(resource_name)
      end
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
    # I am sure there's a much better way
    if resource.valid_password?(params[resource_name][:refresh_password])
      if resource.otp_enabled?
        if resource.validate_otp_token(params[resource_name][:token].to_i)
          done_valid_refresh
        else
          failed_refresh
        end
      else
        done_valid_refresh
      end
    else
      failed_refresh
    end
  end


  private

  def done_valid_refresh
    otp_refresh_credentials_for(resource)
    otp_set_flash_message :success, :valid_refresh if is_navigational_format?

    respond_with resource, :location => otp_fetch_refresh_return_url
  end

  def failed_refresh
    otp_set_flash_message :alert, :invalid_refresh
    render :refresh
  end

  def authenticate_scope!
    send(:"authenticate_#{resource_name}!", :force => true)
    self.resource = send("current_#{resource_name}")
  end
end