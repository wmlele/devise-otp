require "test_helper"
require "integration_tests_helper"

class DisableTokenTest < ActionDispatch::IntegrationTest

  def setup
    # log in 1fa
    @user = enable_otp_and_sign_in
    assert_equal user_otp_credential_path, current_path

    # otp 2fa
    fill_in "token", with: ROTP::TOTP.new(@user.otp_auth_secret).at(Time.now)
    click_button "Submit Token"
    assert_equal root_path, current_path
  end

  def teardown
    Capybara.reset_sessions!
  end

  test "disabling OTP after successfully enabling" do
    # disable OTP
    disable_otp

    assert page.has_content? "Disabled"

    # logout
    sign_out

    # log back in 1fa
    sign_user_in(@user)

    assert_equal root_path, current_path
  end

  test "disabling OTP does not reset token secrets" do
    # get otp secrets
    @user.reload
    auth_secret = @user.otp_auth_secret
    recovery_secret = @user.otp_recovery_secret

    # disable OTP
    disable_otp

    # compare otp secrets
    assert_not_nil @user.otp_auth_secret
    assert_equal @user.otp_auth_secret, auth_secret

    assert_not_nil @user.otp_recovery_secret
    assert_equal @user.otp_recovery_secret, recovery_secret
  end

end
