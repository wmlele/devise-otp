require 'rotp'

module Devise::Models
  module OtpAuthenticatable
    extend ActiveSupport::Concern

    included do
      before_validation :generate_otp_auth_secret, :on => :create
      before_validation :generate_otp_persistence_seed, :on => :create
      scope :with_valid_otp_challenge, lambda { |time| { :conditions => ["otp_challenge_expires > ?", time] } }
    end

    module ClassMethods
      ::Devise::Models.config(self, :otp_authentication_timeout, :otp_drift_window,
                                    :otp_mandatory, :otp_credentials_refresh, :otp_uri_application)

      def find_valid_otp_challenge(challenge)
        with_valid_otp_challenge(Time.now).where(:otp_session_challenge => challenge).first
      end
    end

    def time_based_otp
      @time_based_otp ||= ROTP::TOTP.new(otp_auth_secret)
    end

    def sequence_based_otp
      @sequence_based_otp ||= ROTP::HOTP.new(otp_auth_secret)
    end

    def otp_provisioning_uri
      time_based_otp.provisioning_uri(otp_provisioning_identifier)
    end

    def otp_provisioning_identifier
      "#{email}/#{self.class.otp_uri_application || Rails.application.class.parent_name}"
    end


    def reset_otp_credentials
      @time_based_otp = nil
      generate_otp_auth_secret
      reset_otp_persistence
      update_attributes({:otp_enabled => false, :otp_time_drift => 0,
                         :otp_session_challenge => nil, :otp_challenge_expires => nil,
                         :otp_recovery_counter => 0 }, :without_protection => true)
    end

    def reset_otp_credentials!
      reset_otp_credentials
      save!
    end


    def reset_otp_persistence
      generate_otp_persistence_seed
    end

    def reset_otp_persistence!
      reset_otp_persistence
      save!
    end

    def generate_otp_challenge!(expires = nil)
      update_attributes({:otp_session_challenge => SecureRandom.hex,
                         :otp_challenge_expires => DateTime.now + (expires || self.class.otp_authentication_timeout)},
                        :without_protection => true )
      otp_session_challenge
    end

    def otp_challenge_valid?
      (otp_challenge_expires.nil? || otp_challenge_expires > Time.now)
    end


    def validate_otp_token(token)
      if drift = validate_otp_token_with_drift(token)
        update_attribute(:otp_time_drift, drift)
        true
      else
        false
      end
    end
    alias_method :valid_otp_token?, :validate_otp_token

    def next_otp_recovery_tokens(number = 5)
      (otp_recovery_counter..otp_recovery_counter + number).inject({}) do |h, index|
        h[index] = sequence_based_otp.at(index)
        h
      end
    end

    def validate_otp_recovery_token(token)
      token = token.to_i unless token.is_a?(Fixnum)
      sequence_based_otp.verify(token, otp_recovery_counter).tap do
        self.otp_recovery_counter += 1
        save!
      end
    end
    alias_method :valid_otp_recovery_token?, :validate_otp_recovery_token





    private

    #
    # refactor me, I suck
    #
    def validate_otp_token_with_drift(token)
      # valid_vals << ROTP::TOTP.new(otp_auth_secret).at(Time.now)
      token = token.to_i unless token.is_a?(Fixnum)

      # should be centered around saved drift
      (-self.class.otp_drift_window..self.class.otp_drift_window).each do |drift|
        return drift if(time_based_otp.verify(token, Time.now.ago(30 * drift)))
      end
      false
    end

    def generate_otp_persistence_seed
      self.otp_persistence_seed = SecureRandom.hex
    end

    def generate_otp_auth_secret
      self.otp_auth_secret = ROTP::Base32.random_base32
    end

  end
end