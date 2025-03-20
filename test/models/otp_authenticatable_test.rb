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
    now = Time.now.utc
    user.update(
      :otp_failed_attempts => 1,
      :otp_recovery_forced_until => now,
      :otp_by_email_counter => 1,
      :otp_by_email_token_expires => now,
      :otp_recovery_counters => "[1,2,3]",
    )

    assert user.otp_enabled
    [:otp_auth_secret, :otp_recovery_secret, :otp_persistence_seed, :otp_recovery_forced_until, :otp_by_email_token_expires].each do |field|
      assert_not_nil user.send(field)
    end
    [:otp_failed_attempts, :otp_by_email_counter].each do |field|
      assert_not user.send(field) == 0
    end
    assert user.otp_recovery_counters != "[]"

    user.clear_otp_fields!
    [:otp_auth_secret, :otp_recovery_secret, :otp_persistence_seed, :otp_recovery_forced_until, :otp_by_email_token_expires].each do |field|
      assert_nil user.send(field)
    end
    [:otp_failed_attempts, :otp_by_email_counter].each do |field|
      assert user.send(field) == 0
    end
    assert user.otp_recovery_counters == "[]"
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
    recovery = u.otp_recovery_tokens

    assert u.valid_otp_recovery_token? recovery[5]
    assert_nil u.valid_otp_recovery_token?(recovery[5])
    assert u.valid_otp_recovery_token? recovery[2]
  end

  test "max_failed_attempts_exceeded? is true when failed_attempts > otp_max_failed_attempts" do
    user = User.new
    otp_max_failed_attempts = user.class.otp_max_failed_attempts

    user.update(otp_failed_attempts: otp_max_failed_attempts-1)
    assert user.otp_failed_attempts < otp_max_failed_attempts
    assert_equal user.max_failed_attempts_exceeded?, false

    user.update(otp_failed_attempts: otp_max_failed_attempts)
    assert user.otp_failed_attempts = otp_max_failed_attempts
    assert_equal user.max_failed_attempts_exceeded?, false

    user.update(otp_failed_attempts: otp_max_failed_attempts+1)
    assert user.otp_failed_attempts > otp_max_failed_attempts
    assert_equal user.max_failed_attempts_exceeded?, true
  end

  test "within_recovery_timeout? is true when current time is before otp_recovery_forced_until" do
    user = User.new
    now = Time.now.utc

    assert_nil user.otp_recovery_forced_until
    assert_equal user.within_recovery_timeout?(now), false

    user.update(otp_recovery_forced_until: now)
    assert_equal user.within_recovery_timeout?(now-1), true
    assert_equal user.within_recovery_timeout?(now), false
    assert_equal user.within_recovery_timeout?(now+1), false
  end

  test "reset_failed_attempts sets otp_failed_attemps to 0, and otp_recovery_forced_until to nil" do
    user = User.first
    user.update!(otp_failed_attempts: 12, otp_recovery_forced_until: Time.now.utc)

    user.reset_failed_attempts
    assert_equal user.otp_failed_attempts, 0
    assert_nil user.otp_recovery_forced_until
  end

  test "bump_failed_attempts increases otp_failed_attempts by 1 and sets otp_recovery_forced_until if otp_max_failed_attempts is exceeded" do
    user = User.first
    otp_max_failed_attempts = user.class.otp_max_failed_attempts
    otp_recovery_timeout = user.class.otp_recovery_timeout
    now = Time.now.utc.round(6) # round to microseconds (db limit) to be able to compare values

    user.update!(otp_failed_attempts: otp_max_failed_attempts-2, otp_recovery_forced_until: nil)

    user.bump_failed_attempts(now)
    assert_equal user.otp_failed_attempts, otp_max_failed_attempts-1
    assert_nil user.otp_recovery_forced_until

    user.bump_failed_attempts(now)
    assert_equal user.otp_failed_attempts, otp_max_failed_attempts
    assert_nil user.otp_recovery_forced_until

    user.bump_failed_attempts(now)
    assert_equal user.otp_failed_attempts, otp_max_failed_attempts+1
    assert user.otp_recovery_forced_until.eql?(now+otp_recovery_timeout)
  end

  test "otp_by_email_token_expired? true if otp_by_email_token_expires blank or before provided time" do
    user = User.new
    now = Time.now.utc

    assert_nil user.otp_by_email_token_expires
    assert_equal user.otp_by_email_token_expired?, true

    user.update(otp_by_email_token_expires: now)
    assert_equal user.otp_by_email_token_expired?, true

    user.update(otp_by_email_token_expires: now+1)
    assert_equal user.otp_by_email_token_expired?, false
  end

  test "otp_by_email_advance_counter bumps otp_by_email_counter and sets otp_by_email_token_expires" do
    user = User.first
    user.update!(otp_by_email_counter: 0, otp_by_email_token_expires: nil)
    now = Time.now.utc.round(6)
    otp_by_email_code_valid_for = user.class.otp_by_email_code_valid_for

    user.otp_by_email_advance_counter(now)
    assert_equal user.otp_by_email_counter, 1
    assert user.otp_by_email_token_expires.eql?(now+otp_by_email_code_valid_for)

    user.otp_by_email_advance_counter(now+1)
    assert_equal user.otp_by_email_counter, 2
    assert user.otp_by_email_token_expires.eql?(now+otp_by_email_code_valid_for+1)
  end
end
