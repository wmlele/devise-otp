require "test_helper"
require "integration_tests_helper"

class ResetTokenTest < ActionDispatch::IntegrationTest

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

  test "redirects to otp_tokens#edit page" do
    reset_otp

    assert_equal "/users/otp/token/edit", current_path
    within "#alerts" do
      assert page.has_content? 'Your token secret has been reset. Please confirm your new token secret below.'
    end
  end

  test "generates new token secrets" do
    # get auth secrets
    auth_secret = @user.otp_auth_secret
    recovery_secret = @user.otp_recovery_secret

    # reset otp
    reset_otp

    # compare auth secrets
    @user.reload
    assert_not_nil @user.otp_auth_secret
    assert_not_equal @user.otp_auth_secret, auth_secret

    assert_not_nil @user.otp_recovery_secret
    assert_not_equal @user.otp_recovery_secret, recovery_secret
  end

end
