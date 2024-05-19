require "test_helper"
require "model_tests_helper"

class OtpAuthenticatableTest < ActiveSupport::TestCase
  def setup
    new_user
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
      :otp_failed_attempts => 1,
      :otp_recovery_counter => 1
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
    sleep(2)

    w = User.find_valid_otp_challenge(challenge)
    assert_nil w
  end

  test "expired challenges should not be valid" do
    u = User.first
    u.populate_otp_secrets!
    u.enable_otp!
    challenge = u.generate_otp_challenge!(1.second)
    sleep(2)
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

  test "generated otp token, out of drift window, should be NOT valid for the user" do
    u = User.first
    u.populate_otp_secrets!
    u.enable_otp!

    secret = u.otp_auth_secret

    [3.minutes.from_now, 3.minutes.ago].each do |time|
      token = ROTP::TOTP.new(secret).at(time)
      assert_equal false, u.valid_otp_token?(token)
    end
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
