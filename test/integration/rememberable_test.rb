require "test_helper"
require "integration_tests_helper"

class RememberableTest < ActionDispatch::IntegrationTest
  def teardown
    Capybara.reset_sessions!
    Timecop.return
  end

  test "checking remember_me at the sign in page persists the selection to the OTP credentials page" do
  end

  test "completing the sign in process with OTP enabled remembers the user" do
    assert request.cookies['remember_user_token']
  end

  test "checking remember_me at the sign in page does not remember the user until sign in is completed" do
    assert_nil request.cookies['remember_user_token']
  end

  test "rememberable is distinct from OTP credential persistence" do
    assert_nil request.cookies['remember_user_token']
  end

  test "normal users without rememberable enabled are not affected" do
  end

end
