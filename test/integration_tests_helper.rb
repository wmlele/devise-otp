class ActionDispatch::IntegrationTest
  include Warden::Test::Helpers

  def warden
    request.env['warden']
  end
  
  def create_full_user
    @user ||= begin
      user = User.create!(
        :email                 => 'user@email.invalid',
        :password              => '12345678',
        :password_confirmation => '12345678'
      )
      user
    end
  end

  def enable_otp_and_sign_in_with_otp
    enable_otp_and_sign_in.tap do |user|
      fill_in 'user_token', :with => ROTP::TOTP.new(user.otp_auth_secret).at(Time.now)
      click_button 'Submit Token'
    end
  end

  def enable_otp_and_sign_in
    user = create_full_user
    sign_user_in(user)
    visit user_otp_token_path
    check 'user_otp_enabled'
    click_button 'Continue...'

    Capybara.reset_sessions!

    sign_user_in(user)
    user
  end

  def otp_challenge_for(user)
    fill_in 'user_token', :with => ROTP::TOTP.new(user.otp_auth_secret).at(Time.now)
    click_button 'Submit Token'
  end

  def disable_otp
    visit user_otp_token_path
    uncheck 'user_otp_enabled'
    click_button 'Continue...'
  end

  def sign_out
    logout :user
  end

  def sign_user_in(user = nil)
    user ||= create_full_user
    resource_name = user.class.name.underscore
    visit send("new_#{resource_name}_session_path")
    fill_in "#{resource_name}_email", :with => user.email
    fill_in "#{resource_name}_password", :with => user.password

    page.has_content?('Log in') ? click_button('Log in') : click_button('Sign in')
    user
  end

end
