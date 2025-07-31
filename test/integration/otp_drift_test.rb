require "test_helper"
require "integration_tests_helper"

class OtpDriftTest < ActionDispatch::IntegrationTest
  def teardown
    Capybara.reset_sessions!
    Timecop.return
  end

  test "should allow OTP token usage up within the OTP drift window" do
    user = enable_otp_and_sign_in

    copied_token = ROTP::TOTP.new(user.otp_auth_secret).at(Time.now)

    Timecop.freeze(Time.now + 90)

    fill_in "token", with: copied_token
    click_button "Submit Token"

    assert_equal root_path, current_path
  end

  test "should not allow OTP token usage beyond the OTP drift window" do
    user = enable_otp_and_sign_in

    copied_token = ROTP::TOTP.new(user.otp_auth_secret).at(Time.now)

    Timecop.freeze(Time.now + 120)

    fill_in "token", with: copied_token
    click_button "Submit Token"

    assert_not_equal root_path, current_path
  end

end
