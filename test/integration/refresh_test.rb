require "test_helper"
require "integration_tests_helper"

class RefreshTest < ActionDispatch::IntegrationTest
  def teardown
    Capybara.reset_sessions!
    travel_back
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

    travel_to(15.minutes.from_now + 1.second)

    visit user_otp_token_path
    assert_equal refresh_user_otp_credential_path, current_path
  end

  test "a user should be able to access their OTP settings after refreshing" do
    sign_user_in
    visit user_otp_token_path
    assert_equal user_otp_token_path, current_path

    travel_to(15.minutes.from_now + 1.second)

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

    travel_to(15.minutes.from_now + 1.second)

    visit user_otp_token_path
    assert_equal refresh_user_otp_credential_path, current_path

    fill_in "user_refresh_password", with: "12345670"
    click_button "Continue..."
    assert_equal refresh_user_otp_credential_path, current_path

    within "#alerts" do
      assert page.has_content? 'Sorry, you provided the wrong credentials.'
    end

    visit "/"
    within "#alerts" do
      assert !page.has_content?('Sorry, you provided the wrong credentials.')
    end
  end

  test "user should be finally be able to access their settings, and just password is enough" do
    enable_otp_and_sign_in_with_otp

    travel_to(15.minutes.from_now + 1.second)

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

    visit new_admin_session_path
    fill_in "admin_email", with: admin.email
    fill_in "admin_password", with: admin.password

    page.has_content?("Log in") ? click_button("Log in") : click_button("Sign in")

    assert_equal admin_otp_credential_path, current_path

    fill_in "token", with: ROTP::TOTP.new(admin.otp_auth_secret).at(Time.now)
    click_button "Submit Token"
    assert_equal "/", current_path

    travel_to(15.minutes.from_now + 1.second)

    visit admin_otp_token_path
    assert_equal refresh_admin_otp_credential_path, current_path

    fill_in "admin_refresh_password", with: "12345678"
    click_button "Continue..."

    assert_equal admin_otp_token_path, current_path
  end

  test "failed credentials should return a 422 'unprocessable entity' status" do
    sign_user_in
    visit user_otp_token_path
    assert_equal user_otp_token_path, current_path

    travel_to(15.minutes.from_now + 1.second)

    visit user_otp_token_path
    assert_equal refresh_user_otp_credential_path, current_path

    fill_in "user_refresh_password", with: "12345670"
    click_button "Continue..."

    assert_equal 422, page.status_code
  end

end
