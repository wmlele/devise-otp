require "test_helper"
require "integration_tests_helper"

class EnableOtpFormTest < ActionDispatch::IntegrationTest
  def teardown
    Capybara.reset_sessions!
  end

  test "a user should be able enable their OTP authentication by entering a confirmation code" do
    user = sign_user_in

    visit edit_user_otp_token_path

    user.reload

    fill_in "confirmation_code", with: ROTP::TOTP.new(user.otp_auth_secret).at(Time.now)

    click_button "Continue..."

    assert_equal user_otp_token_path, current_path
    assert page.has_content?("Enabled")

    within "#alerts" do
      assert page.has_content? 'Your Two-Factor Authentication settings have been updated.'
    end

    user.reload
    assert user.otp_enabled?
  end

  test "a user should not be able enable their OTP authentication with an incorrect confirmation code" do
    user = sign_user_in

    visit edit_user_otp_token_path

    fill_in "confirmation_code", with: "123456"

    click_button "Continue..."

    assert page.has_content?("To Enable Two-Factor Authentication")

    user.reload
    assert_not user.otp_enabled?

    within "#alerts" do
      assert page.has_content? 'The Confirmation Code you entered did not match the QR code shown below.'
    end

    visit "/"
    within "#alerts" do
      assert !page.has_content?('The Confirmation Code you entered did not match the QR code shown below.')
    end
  end

  test "a user should not be able enable their OTP authentication with a blank confirmation code" do
    user = sign_user_in

    visit edit_user_otp_token_path

    fill_in "confirmation_code", with: ""

    click_button "Continue..."

    assert page.has_content?("To Enable Two-Factor Authentication")

    within "#alerts" do
      assert page.has_content? 'The Confirmation Code you entered did not match the QR code shown below.'
    end

    user.reload
    assert_not user.otp_enabled?
  end

  test "failed confirmation code should return a 422 'unprocessable entity' status" do
    user = sign_user_in

    visit edit_user_otp_token_path

    fill_in "confirmation_code", with: "123456"

    click_button "Continue..."

    assert_equal 422, page.status_code
  end
end
