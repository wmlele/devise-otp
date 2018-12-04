require 'test_helper'
require 'model_tests_helper'

class OtpAuthenticatableTest < ActiveSupport::TestCase

  def setup
    new_user
  end

  test 'new users have a non-nil secret set' do
    assert_not_nil User.first.otp_auth_secret
  end

  test 'new users have OTP disabled by default' do
    assert !User.first.otp_enabled
  end

  test 'users should have an instance of TOTP/ROTP objects' do
    u = User.first
    assert u.time_based_otp.is_a? ROTP::TOTP
    assert u.recovery_otp.is_a? ROTP::HOTP
  end

  test 'users should have their otp_auth_secret/persistence_seed set on creation' do
    assert User.first.otp_auth_secret
    assert User.first.otp_persistence_seed
  end

  test 'reset_otp_credentials should generate new secrets and disable OTP' do
    u = User.first
    u.update_attribute(:otp_enabled, true)
    assert u.otp_enabled
    otp_auth_secret = u.otp_auth_secret
    otp_persistence_seed = u.otp_persistence_seed

    u.reset_otp_credentials!
    assert !(otp_auth_secret == u.otp_auth_secret)
    assert !(otp_persistence_seed == u.otp_persistence_seed)
    assert !u.otp_enabled
  end

  test 'reset_otp_persistence should generate new persistence_seed but NOT change the otp_auth_secret' do
    u = User.first
    u.update_attribute(:otp_enabled, true)
    assert u.otp_enabled
    otp_auth_secret = u.otp_auth_secret
    otp_persistence_seed = u.otp_persistence_seed

    u.reset_otp_persistence!
    assert (otp_auth_secret == u.otp_auth_secret)
    assert !(otp_persistence_seed == u.otp_persistence_seed)
    assert u.otp_enabled
  end

  test 'generating a challenge, should retrieve the user later' do
    u = User.first
    u.update_attribute(:otp_enabled, true)
    challenge = u.generate_otp_challenge!

    w = User.find_valid_otp_challenge(challenge)
    assert w.is_a? User
    assert_equal w,u
  end

  test 'expiring the challenge, should retrieve nothing' do
    u = User.first
    u.update_attribute(:otp_enabled, true)
    challenge = u.generate_otp_challenge!(1.second)
    sleep(2)

    w = User.find_valid_otp_challenge(challenge)
    assert_nil w
  end

  test 'expired challenges should not be valid' do
    u = User.first
    u.update_attribute(:otp_enabled, true)
    u.generate_otp_challenge!(1.second)
    sleep(2)
    assert_equal false, u.otp_challenge_valid?
  end

  test 'null otp challenge' do
    u = User.first
    u.update_attribute(:otp_enabled, true)
    assert_equal false, u.validate_otp_token('')
    assert_equal false, u.validate_otp_token(nil)
  end

  test 'generated otp token should be valid for the user' do
    u = User.first
    u.update_attribute(:otp_enabled, true)

    secret = u.otp_auth_secret
    token = ROTP::TOTP.new(secret).now

    assert_equal true, u.validate_otp_token(token)
  end

  test 'generated otp token, out of drift window, should be NOT valid for the user' do
    u = User.first
    u.update_attribute(:otp_enabled, true)

    secret = u.otp_auth_secret

    [3.minutes.from_now, 3.minutes.ago].each do |time|
      token = ROTP::TOTP.new(secret).at(time)
      assert_equal false, u.valid_otp_token?(token)
    end
  end

  test 'recovery secrets should be valid, and valid only once' do
    u = User.first
    u.update_attribute(:otp_enabled, true)
    recovery = u.next_otp_recovery_tokens

    assert u.valid_otp_recovery_token? recovery.fetch(0)
    assert_equal false, u.valid_otp_recovery_token?(recovery.fetch(0))
    assert u.valid_otp_recovery_token? recovery.fetch(2)
  end

end
