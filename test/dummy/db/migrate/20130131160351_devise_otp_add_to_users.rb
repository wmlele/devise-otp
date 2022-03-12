class DeviseOtpAddToUsers < ActiveRecord::Migration[5.0]
  def self.up
    change_table :users do |t|
      t.string    :otp_auth_secret
      t.string    :otp_recovery_secret
      t.boolean   :otp_enabled,          :default => false, :null => false
      t.boolean   :otp_mandatory,        :default => false, :null => false
      t.datetime  :otp_enabled_on
      t.integer   :otp_time_drift,       :default => 0, :null => false
      t.integer   :otp_failed_attempts,  :default => 0, :null => false
      t.integer   :otp_recovery_counter, :default => 0, :null => false
      t.string    :otp_persistence_seed

      t.string    :otp_session_challenge
      t.datetime  :otp_challenge_expires
    end

    add_index :users, :otp_session_challenge,  :unique => true
    add_index :users, :otp_challenge_expires
  end

  def self.down
    change_table :users do |t|
      t.remove :otp_auth_secret, :otp_recovery_secret, :otp_enabled, :otp_mandatory, :otp_enabled_on, :otp_session_challenge,
          :otp_challenge_expires, :otp_time_drift, :otp_failed_attempts, :otp_recovery_counter, :otp_persistence_seed
    end
  end
end
