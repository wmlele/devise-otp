require "test_helper"
require "integration_tests_helper"

class NonOtpUserModelsTest < ActionDispatch::IntegrationTest

  def teardown
    Capybara.reset_sessions!
  end

  test "a non-OTP user should be able to sign in without error" do
    create_non_otp_user

    visit non_otp_posts_path
    fill_in "non_otp_user_email", with: "non-otp-user@email.invalid"
    fill_in "non_otp_user_password", with: "12345678"
    page.has_content?("Log in") ? click_button("Log in") : click_button("Sign in")

    assert_equal non_otp_posts_path, current_path
  end

end
