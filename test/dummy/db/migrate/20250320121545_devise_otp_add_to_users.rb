class DeviseOtpAddToUsers < ActiveRecord::Migration[7.0]
  def self.up
    change_table :users do |t|
      t.string    :otp_auth_secret
      t.string    :otp_recovery_secret
      t.boolean   :otp_enabled,          :default => false, :null => false
      t.boolean   :otp_mandatory,        :default => false, :null => false
      t.datetime  :otp_enabled_on
      t.integer   :otp_failed_attempts,  :default => 0, :null => false
      t.text      :otp_recovery_counters, default: "[]"
      t.datetime  :otp_recovery_forced_until
      t.string    :otp_persistence_seed

      t.boolean   :otp_by_email_enabled,    :default => false, :null => false
      t.integer   :otp_by_email_counter,    :default => 0, :null => false
      t.datetime  :otp_by_email_token_expires

      t.string    :otp_session_challenge
      t.datetime  :otp_challenge_expires
    end
    add_index :users, :otp_session_challenge,  :unique => true
    add_index :users, :otp_challenge_expires
  end

  def self.down
    change_table :users do |t|
      t.remove :otp_auth_secret, :otp_recovery_secret, :otp_enabled, :otp_mandatory, :otp_enabled_on, :otp_session_challenge,
          :otp_challenge_expires, :otp_failed_attempts, :otp_persistence_seed, :otp_recovery_forced_until, :otp_recovery_counters,
          :otp_by_email_enabled, :otp_by_email_counter, :otp_by_email_token_expires
    end
  end
end
