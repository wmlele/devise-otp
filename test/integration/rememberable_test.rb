require "test_helper"
require "integration_tests_helper"

class RememberableTest < ActionDispatch::IntegrationTest
  def setup
    @rememberable_user = create_rememberable_user
    @rememberable_user.populate_otp_secrets!
    @rememberable_user.enable_otp!
  end

  def teardown
    Capybara.reset_sessions!
    Timecop.return
  end

  test "checking remember_me at the sign in page persists the selection to the OTP credentials page" do
    visit new_rememberable_user_session_path

    fill_in "rememberable_user_email", with: "rememberable-user@email.invalid"
    fill_in "rememberable_user_password", with: "12345678"
    check "Remember me"
    click_button("Log in")

    assert_equal rememberable_user_otp_credential_path, current_path

    assert_equal "true", find("#remember_me", visible: false).value
  end

  test "the OTP credentials page persists the remember_me value through any reloads" do
    visit new_rememberable_user_session_path

    fill_in "rememberable_user_email", with: "rememberable-user@email.invalid"
    fill_in "rememberable_user_password", with: "12345678"
    check "Remember me"
    click_button("Log in")
    assert_equal rememberable_user_otp_credential_path, current_path

    fill_in "token", with: "123456"
    click_button("Submit Token")
    assert_equal rememberable_user_otp_credential_path, current_path

    assert_equal "true", find("#remember_me", visible: false).value
  end

  test "completing the sign in process with OTP enabled remembers the user" do
    visit new_rememberable_user_session_path

    fill_in "rememberable_user_email", with: "rememberable-user@email.invalid"
    fill_in "rememberable_user_password", with: "12345678"
    check "Remember me"
    click_button("Log in")
    assert_equal rememberable_user_otp_credential_path, current_path

    fill_in "token", with: ROTP::TOTP.new(@rememberable_user.otp_auth_secret).at(Time.now)
    click_button("Submit Token")

    assert current_path, "/"
    assert cookies['remember_rememberable_user_token']
  end

  test "checking remember_me at the sign in page does not remember the user until sign in is completed" do
    #assert_nil request.cookies['remember_user_token']
  end

  test "rememberable is distinct from OTP credential persistence" do
    #assert_nil request.cookies['remember_user_token']
  end

  test "rememberable users without OTP enabled are remembered immediately" do
    @rememberable_user.disable_otp!
    visit new_rememberable_user_session_path

    fill_in "rememberable_user_email", with: "rememberable-user@email.invalid"
    fill_in "rememberable_user_password", with: "12345678"
    check "Remember me"
    click_button("Log in")

    assert current_path, "/"
    assert cookies['remember_rememberable_user_token']
  end

  test "normal users without rememberable strategy are not affected" do
    create_full_user
    visit new_user_session_path

    assert_not page.has_content? "Remember me"

    fill_in "user_email", with: "user@email.invalid"
    fill_in "user_password", with: "12345678"
  end

end
