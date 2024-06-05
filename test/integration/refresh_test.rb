require "test_helper"
require "integration_tests_helper"

class RefreshTest < ActionDispatch::IntegrationTest
  def setup
    @old_refresh = User.otp_credentials_refresh
    User.otp_credentials_refresh = 1.second
    Admin.otp_credentials_refresh = 1.second
  end

  def teardown
    User.otp_credentials_refresh = @old_refresh
    Admin.otp_credentials_refresh = @old_refresh
    Capybara.reset_sessions!
  end

  test "a user that just signed in should be able to access their OTP settings without refreshing" do
    sign_user_in

    visit user_otp_token_path
    assert_equal user_otp_token_path, current_path
  end

  test "a user should be prompted for credentials when the credentials_refresh time is expired" do
    sign_user_in
    visit user_otp_token_path
    assert_equal user_otp_token_path, current_path

    sleep(2)

    visit user_otp_token_path
    assert_equal refresh_user_otp_credential_path, current_path
  end

  test "a user should be able to access their OTP settings after refreshing" do
    sign_user_in
    visit user_otp_token_path
    assert_equal user_otp_token_path, current_path

    sleep(2)

    visit user_otp_token_path
    assert_equal refresh_user_otp_credential_path, current_path

    fill_in "user_refresh_password", with: "12345678"
    click_button "Continue..."
    assert_equal user_otp_token_path, current_path
  end

  test "a user should NOT be able to access their OTP settings unless refreshing" do
    sign_user_in
    visit user_otp_token_path
    assert_equal user_otp_token_path, current_path

    sleep(2)

    visit user_otp_token_path
    assert_equal refresh_user_otp_credential_path, current_path

    fill_in "user_refresh_password", with: "12345670"
    click_button "Continue..."
    assert_equal refresh_user_otp_credential_path, current_path
  end

  test "user should be finally be able to access their settings, and just password is enough" do
    user = enable_otp_and_sign_in_with_otp

    sleep(2)
    visit user_otp_token_path
    assert_equal refresh_user_otp_credential_path, current_path

    fill_in "user_refresh_password", with: "12345678"
    click_button "Continue..."

    assert_equal user_otp_token_path, current_path
  end

  test "works for non-default warden scopes" do
    admin = create_full_admin

    admin.populate_otp_secrets!
    admin.enable_otp!

    sign_user_in(admin)

    fill_in "admin_token", with: ROTP::TOTP.new(admin.otp_auth_secret).at(Time.now)
    click_button "Submit Token"
    assert_equal "/", current_path

    sleep(2)

    visit admin_otp_token_path
    assert_equal refresh_admin_otp_credential_path, current_path

    fill_in "admin_refresh_password", with: "12345678"
    click_button "Continue..."

    assert_equal admin_otp_token_path, current_path
  end

end
