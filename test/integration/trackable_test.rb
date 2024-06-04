require "test_helper"
require "integration_tests_helper"

class TrackableTest < ActionDispatch::IntegrationTest
  def teardown
    Capybara.reset_sessions!
  end

  test "should not update devise trackable fields until user enters user token" do
    user = sign_user_in

    user.reload

    sign_in_count = user.sign_in_count
    current_sign_in_at = user.current_sign_in_at

    sign_out

    user.populate_otp_secrets!
    user.enable_otp!

    sign_user_in(user)

    user.reload

    assert_equal sign_in_count, user.sign_in_count
    assert_equal current_sign_in_at, user.current_sign_in_at

    fill_in "user_token", with: ROTP::TOTP.new(user.otp_auth_secret).at(Time.now)
    click_button "Submit Token"

    user.reload

    assert_not_equal sign_in_count, user.sign_in_count
    assert_not_equal current_sign_in_at, user.current_sign_in_at
  end

end
