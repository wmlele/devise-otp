require "test_helper"
require "integration_tests_helper"

class EnableOtpFormTest < ActionDispatch::IntegrationTest
  def teardown
    Capybara.reset_sessions!
  end

  test "a user should be able enable their OTP authentication by entering a confirmation code" do
    user = sign_user_in

    visit edit_user_otp_token_path

    fill_in "otp_token", with: ROTP::TOTP.new(user.otp_auth_secret).at(Time.now)

    click_button "Continue..."

    assert_equal user_otp_token_path, current_path
    assert page.has_content?("Enabled")

    assert user.otp_auth_secret.enabled?
    assert !user.otp_auth_secret.nil?
    assert !user.otp_persistence_seed.nil?
  end

  test "a user should not be able enable their OTP authentication with an incorrect confirmation code" do
    user = sign_user_in

    visit edit_user_otp_token_path

    fill_in "otp_token", with: "123456"

    click_button "Continue..."

    assert page.has_content?("did not match")

    assert !user.otp_auth_secret.enabled?
  end

  test "a user should not be able enable their OTP authentication with a blank confirmation code" do
    user = sign_user_in

    visit edit_user_otp_token_path

    fill_in "otp_token", with: ""

    click_button "Continue..."

    assert page.has_content?("did not match")

    assert !user.otp_auth_secret.enabled?
  end

end
