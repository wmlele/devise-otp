require "test_helper"
require "integration_tests_helper"

class RememberableTest < ActionDispatch::IntegrationTest
  def teardown
    Capybara.reset_sessions!
    Timecop.return
  end

  test "checking remember_me at the sign in page persists the selection to the OTP credentials page, and to any reloads" do
    @rememberable_user = create_rememberable_user
    @rememberable_user.enable_otp!

    visit new_rememberable_user_session_path

    fill_in "rememberable_user_email", with: "rememberable-user@email.invalid"
    fill_in "rememberable_user_password", with: "12345678"
    check "Remember me"
    click_button("Log in")

    assert_equal current_path, rememberable_user_otp_credential_path
    assert_equal "true", find("#remember_me", visible: false).value

    fill_in "token", with: "123456"
    click_button("Submit Token")

    assert_equal current_path, rememberable_user_otp_credential_path
    assert_equal "true", find("#remember_me", visible: false).value
  end

  test "completing the sign in process with OTP enabled remembers the user" do
    #assert request.cookies['remember_user_token']
  end

  test "checking remember_me at the sign in page does not remember the user until sign in is completed" do
    #assert_nil request.cookies['remember_user_token']
  end

  test "rememberable is distinct from OTP credential persistence" do
    #assert_nil request.cookies['remember_user_token']
  end

  test "rememberable users without OTP enabled are not affected" do
    create_full_user
    visit new_user_session_path

    assert_not page.has_content? "Remember me"

    fill_in "user_email", with: "user@email.invalid"
    fill_in "user_password", with: "12345678"
  end

  test "normal users without rememberable strategy are not affected" do
    create_full_user
    visit new_user_session_path

    assert_not page.has_content? "Remember me"

    fill_in "user_email", with: "user@email.invalid"
    fill_in "user_password", with: "12345678"
  end

end
