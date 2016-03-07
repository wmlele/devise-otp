require 'test_helper'
require 'integration_tests_helper'

class SignInTest < ActionDispatch::IntegrationTest

  def teardown
    Capybara.reset_sessions!
  end

  test 'a new user should be able to sign in without using their token' do
    create_full_user

    visit posts_path
    fill_in 'user_email', :with => 'user@email.invalid'
    fill_in 'user_password', :with => '12345678'
    page.has_content?('Log in') ? click_button('Log in') : click_button('Sign in')

    assert_equal posts_path, current_path
  end

  test 'a new user, just signed in, should be able to sign in and enable their OTP authentication' do
    user = sign_user_in

    visit user_otp_token_path
    assert !page.has_content?('Your token secret')

    check 'user_otp_enabled'
    click_button 'Continue...'

    assert_equal user_otp_token_path, current_path

    assert page.has_content?('Your token secret')
    assert !user.otp_auth_secret.nil?
    assert !user.otp_persistence_seed.nil?
  end

  test 'a new user should be able to sign in enable OTP and be prompted for their token' do
    enable_otp_and_sign_in

    assert_equal user_otp_credential_path, current_path
  end

  test 'fail token authentication' do
    enable_otp_and_sign_in
    assert_equal user_otp_credential_path, current_path

    fill_in 'user_token', :with => '123456'
    click_button 'Submit Token'

    assert_equal new_user_session_path, current_path
  end

  test 'fail blank token authentication' do
    enable_otp_and_sign_in
    assert_equal user_otp_credential_path, current_path

    fill_in 'user_token', :with => ''
    click_button 'Submit Token'

    assert_equal user_otp_credential_path, current_path
  end

  test 'successful token authentication' do
    user = enable_otp_and_sign_in

    fill_in 'user_token', :with => ROTP::TOTP.new(user.otp_auth_secret).at(Time.now)
    click_button 'Submit Token'

    assert_equal root_path, current_path
  end


  test 'should fail if the the challenge times out' do
    old_timeout = User.otp_authentication_timeout
    User.otp_authentication_timeout = 1.second

    user = enable_otp_and_sign_in

    sleep(2)

    fill_in 'user_token', :with => ROTP::TOTP.new(user.otp_auth_secret).at(Time.now)
    click_button 'Submit Token'

    User.otp_authentication_timeout = old_timeout
    assert_equal new_user_session_path, current_path
  end
end