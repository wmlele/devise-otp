require "test_helper"
require "integration_tests_helper"

class SignInTest < ActionDispatch::IntegrationTest
  def setup
    @lockable_user = create_lockable_user
    @lockable_user.populate_otp_secrets!
    @lockable_user.update(otp_enabled: true)

    sign_user_in(@lockable_user)
    assert_equal lockable_user_otp_credential_path, current_path
  end

  def teardown
    Capybara.reset_sessions!
  end

  test "a normal User should not get locked out for entering incorrect OTP tokens" do
    enable_otp_and_sign_in

    6.times do
      fill_in "token", with: "123456"
      click_button "Submit Token"
    end

    assert page.has_content? "The token you provided was invalid."
  end

  test "a Lockable User should increment failed_attempts for each incorrect OTP token" do
    fill_in "token", with: "123456"
    click_button "Submit Token"
    assert page.has_content? "The token you provided was invalid."

    @lockable_user.reload
    assert_equal 1, @lockable_user.failed_attempts

    fill_in "token", with: "123456"
    click_button "Submit Token"
    assert page.has_content? "The token you provided was invalid."

    @lockable_user.reload
    assert_equal 2, @lockable_user.failed_attempts
  end

  test "a Lockable User should reset failed_attempts after a correct OTP token" do
    fill_in "token", with: ROTP::TOTP.new(@lockable_user.otp_auth_secret).at(Time.now)
    click_button "Submit Token"
    assert_equal root_path, current_path

    @lockable_user.reload
    assert_equal 0, @lockable_user.failed_attempts
  end

  test "a Lockable User should get locked out for entering incorrect OTP token too many times" do
    # Enter incorrect token
    5.times do
      fill_in "token", with: "123456"
      click_button "Submit Token"
    end

    @lockable_user.reload
    assert @lockable_user.access_locked?
  end

  test "a locked out user should be redirected to the sign in form" do
    # Enter incorrect token
    5.times do
      fill_in "token", with: "123456"
      click_button "Submit Token"
    end

    assert_equal new_lockable_user_session_path, current_path
  end

  test "a locked out user should see the default 'Your account is locked' message" do
    # Enter incorrect token
    5.times do
      fill_in "token", with: "123456"
      click_button "Submit Token"
    end

    assert page.has_content? "Your account is locked."
  end

  test "the OTP credentials form should display the 'one more attempt' message before being locked out" do
    # Enter incorrect token
    4.times do
      fill_in "token", with: "123456"
      click_button "Submit Token"
    end

    assert page.has_content? "You have one more attempt"
  end

  test "the OTP credentials form should not work for a locked out user (in case of URL revisit)" do
    # Save challenge path
    uri = URI.parse(current_url)
    challenge_path = "#{uri.path}?#{uri.query}"

    # Enter incorrect token
    5.times do
      fill_in "token", with: "123456"
      click_button "Submit Token"
    end

    visit challenge_path

    # Enter correct token
    fill_in "token", with: ROTP::TOTP.new(@lockable_user.otp_auth_secret).at(Time.now)
    click_button "Submit Token"

    assert page.has_content? "Your account is locked."
  end
end
