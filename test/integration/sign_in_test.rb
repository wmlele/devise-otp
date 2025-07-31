require "test_helper"
require "integration_tests_helper"

class SignInTest < ActionDispatch::IntegrationTest
  def teardown
    Capybara.reset_sessions!
    Timecop.return
  end

  test "a new user should be able to sign in without using their token" do
    create_full_user

    visit posts_path
    fill_in "user_email", with: "user@email.invalid"
    fill_in "user_password", with: "12345678"
    page.has_content?("Log in") ? click_button("Log in") : click_button("Sign in")

    assert_equal posts_path, current_path
  end

  test "a new user, just signed in, should be able to see and click the 'Enable Two-Factor Authentication' link" do
    user = sign_user_in

    visit user_otp_token_path
    assert page.has_content?("Disabled")

    click_link "Enable Two-Factor Authentication"

    assert page.has_content?("Enable Two-Factor Authentication")
    assert_equal edit_user_otp_token_path, current_path
  end

  test "a new user should be able to sign in enable OTP and be prompted for their token" do
    enable_otp_and_sign_in

    assert_equal user_otp_credential_path, current_path
  end

  test "fail token authentication" do
    enable_otp_and_sign_in
    assert_equal user_otp_credential_path, current_path

    fill_in "token", with: "123456"
    click_button "Submit Token"

    assert_equal user_otp_credential_path, current_path
    assert page.has_content? "The token you provided was invalid."
  end

  test "fail blank token authentication" do
    enable_otp_and_sign_in
    assert_equal user_otp_credential_path, current_path

    fill_in "token", with: ""
    click_button "Submit Token"

    assert_equal user_otp_credential_path, current_path
    assert page.has_content? "You need to type in the token you generated with your device."
  end

  test "failed authentication should return a 422 'unprocessable entity' status" do
    enable_otp_and_sign_in
    assert_equal user_otp_credential_path, current_path

    fill_in "token", with: "123456"
    click_button "Submit Token"

    assert_equal 422, page.status_code
  end

  test "successful token authentication" do
    user = enable_otp_and_sign_in

    fill_in "token", with: ROTP::TOTP.new(user.otp_auth_secret).at(Time.now)
    click_button "Submit Token"

    assert_equal root_path, current_path
  end

  test "should fail and redirect if the the challenge is expired" do
    user = enable_otp_and_sign_in

    Timecop.travel(Time.now + 3.minutes)

    fill_in "token", with: ROTP::TOTP.new(user.otp_auth_secret).at(Time.now)
    click_button "Submit Token"

    assert_equal new_user_session_path, current_path
  end

  test "blank token flash message does not persist to successful authentication redirect." do
    user = enable_otp_and_sign_in

    fill_in "token", with: "123456"
    click_button "Submit Token"

    assert page.has_content?("The token you provided was invalid.")

    fill_in "token", with: ROTP::TOTP.new(user.otp_auth_secret).at(Time.now)
    click_button "Submit Token"

    assert !page.has_content?("The token you provided was invalid.")
  end

  test "invalid token flash message does not persist to successful authentication redirect." do
    user = enable_otp_and_sign_in

    fill_in "token", with: ""
    click_button "Submit Token"

    assert page.has_content?("You need to type in the token you generated with your device.")

    fill_in "token", with: ROTP::TOTP.new(user.otp_auth_secret).at(Time.now)
    click_button "Submit Token"

    assert !page.has_content?("You need to type in the token you generated with your device.")
  end
end
