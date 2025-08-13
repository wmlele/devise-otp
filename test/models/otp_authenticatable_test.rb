require "test_helper"
require "model_tests_helper"

class OtpAuthenticatableTest < ActiveSupport::TestCase
  def setup
    new_user
  end

  def teardown
    Timecop.return
  end

  test "new users do not have a secret set" do
    user = User.first

    [:otp_auth_secret, :otp_recovery_secret, :otp_persistence_seed].each do |field|
      assert_nil user.send(field)
    end
  end

  test "new users have OTP disabled by default" do
    assert !User.first.otp_enabled
  end

  test "populating otp secrets should populate all required fields" do
    user = User.first
    user.populate_otp_secrets!

    [:otp_auth_secret, :otp_recovery_secret, :otp_persistence_seed].each do |field|
      assert_not_nil user.send(field)
    end
  end

  test "time_based_otp and recover_otp fields should be an instance of TOTP/ROTP objects" do
    user = User.first
    user.populate_otp_secrets!

    assert user.time_based_otp.is_a? ROTP::TOTP
    assert user.recovery_otp.is_a? ROTP::HOTP
  end

  test "clear_otp_fields should clear all otp fields" do
    user = User.first
    user.populate_otp_secrets!

    user.enable_otp!
    user.generate_otp_challenge!
    user.update(
      otp_failed_attempts: 1,
      otp_recovery_counter: 1
    )


    assert user.otp_enabled
    [:otp_auth_secret, :otp_recovery_secret, :otp_persistence_seed].each do |field|
      assert_not_nil user.send(field)
    end
    [:otp_failed_attempts, :otp_recovery_counter].each do |field|
      assert_not user.send(field) == 0
    end

    user.clear_otp_fields!
    [:otp_auth_secret, :otp_recovery_secret, :otp_persistence_seed].each do |field|
      assert_nil user.send(field)
    end
    [:otp_failed_attempts, :otp_recovery_counter].each do |field|
      assert user.send(field) == 0
    end
  end

  test "reset_otp_persistence should generate new persistence_seed but NOT change the otp_auth_secret" do
    u = User.first
    u.populate_otp_secrets!
    u.enable_otp!
    assert u.otp_enabled

    otp_auth_secret = u.otp_auth_secret
    otp_persistence_seed = u.otp_persistence_seed

    u.reset_otp_persistence!
    assert(otp_auth_secret == u.otp_auth_secret)
    assert !(otp_persistence_seed == u.otp_persistence_seed)
    assert u.otp_enabled
  end

  test "generating a challenge, should retrieve the user later" do
    u = User.first
    u.populate_otp_secrets!
    u.enable_otp!
    challenge = u.generate_otp_challenge!

    w = User.find_valid_otp_challenge(challenge)
    assert w.is_a? User
    assert_equal w, u
  end

  test "expiring the challenge, should retrieve nothing" do
    u = User.first
    u.populate_otp_secrets!
    u.enable_otp!
    challenge = u.generate_otp_challenge!(1.second)

    Timecop.travel(Time.now + 2)

    w = User.find_valid_otp_challenge(challenge)
    assert_nil w
  end

  test "expired challenges should not be valid" do
    u = User.first
    u.populate_otp_secrets!
    u.enable_otp!
    challenge = u.generate_otp_challenge!(1.second)
    Timecop.travel(Time.now + 2)
    assert_equal false, u.otp_challenge_valid?
  end

  test "null otp challenge" do
    u = User.first
    u.populate_otp_secrets!
    u.enable_otp!
    assert_equal false, u.validate_otp_token("")
    assert_equal false, u.validate_otp_token(nil)
  end

  test "generated otp token should be valid for the user" do
    u = User.first
    u.populate_otp_secrets!
    u.enable_otp!

    secret = u.otp_auth_secret
    token = ROTP::TOTP.new(secret).now

    assert_equal true, u.validate_otp_token(token)
  end

  test "generated otp token within the drift window should be valid for the user" do
    u = User.first
    u.populate_otp_secrets!
    u.enable_otp!

    secret = u.otp_auth_secret
    token = ROTP::TOTP.new(secret).at(Time.now)

    Timecop.freeze(Time.now + 90)
    assert_equal true, u.valid_otp_token?(token)

    Timecop.return
    Timecop.freeze(Time.now - 90)
    assert_equal true, u.valid_otp_token?(token)
  end

  test "generated otp token outside of drift window should NOT be valid for the user" do
    # Since the otp_drift_window defines steps (not just time), and these steps
    # begin at the 30 and 60 second marks of each minute, it is possible for
    # an OTP token to be used up to 119 seconds after generation with a 3 step
    # drift window. For example, a token generated at 12:00:00PM could be used
    # within the timeframe for any of the following steps:
    # - 12:00:00~12:00:29 (current step)
    # - 12:00:30~12:00:59 (drift of 1 step)
    # - 12:01:00~12:00:29 (drift of 2 steps)
    # - 12:01:30~12:01:59 (drift of 3 steps)
    #
    # As a result, we need to test for 120 seconds to ensure that the test
    # always passes.

    u = User.first
    u.populate_otp_secrets!
    u.enable_otp!

    secret = u.otp_auth_secret
    token = ROTP::TOTP.new(secret).at(Time.now)

    Timecop.freeze(Time.now + 120)
    assert_equal false, u.valid_otp_token?(token)

    Timecop.return
    Timecop.freeze(Time.now - 120)
    assert_equal false, u.valid_otp_token?(token)
  end

  test "recovery secrets should be valid, and valid only once" do
    u = User.first
    u.populate_otp_secrets!
    u.enable_otp!
    recovery = u.next_otp_recovery_tokens

    assert u.valid_otp_recovery_token? recovery.fetch(0)
    assert_nil u.valid_otp_recovery_token?(recovery.fetch(0))
    assert u.valid_otp_recovery_token? recovery.fetch(2)
  end
end
