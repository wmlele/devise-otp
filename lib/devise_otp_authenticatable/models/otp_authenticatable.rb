require 'rotp'

module Devise::Models
  module OtpAuthenticatable
    extend ActiveSupport::Concern

    included do
      before_validation :generate_otp_auth_secret, :on => :create
      before_validation :generate_otp_persistence_seed, :on => :create
      scope :with_valid_otp_challenge, lambda { |time| where('otp_challenge_expires > ?', time) }
    end

    module ClassMethods
      ::Devise::Models.config(self, :otp_authentication_timeout, :otp_drift_window, :otp_trust_persistence,
                                    :otp_mandatory, :otp_credentials_refresh, :otp_issuer, :otp_recovery_tokens)

      def find_valid_otp_challenge(challenge)
        with_valid_otp_challenge(Time.now).where(:otp_session_challenge => challenge).first
      end
    end

    def time_based_otp
      @time_based_otp ||= ROTP::TOTP.new(otp_auth_secret, issuer: "#{self.class.otp_issuer || Rails.application.class.parent_name}")
    end

    def recovery_otp
      @recovery_otp ||= ROTP::HOTP.new(otp_recovery_secret)
    end

    def otp_provisioning_uri
      time_based_otp.provisioning_uri(otp_provisioning_identifier)
    end

    def otp_provisioning_identifier
      email
    end


    def reset_otp_credentials(save = true)
      @time_based_otp = nil
      @recovery_otp = nil
      generate_otp_auth_secret
      reset_otp_persistence
      update_attributes!(:otp_enabled => false,
             :otp_session_challenge => nil, :otp_challenge_expires => nil,
             :otp_recovery_counter => 0) if save
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

    def enable_otp!
      if otp_persistence_seed.nil?
        reset_otp_credentials!
      end

      update_attributes!(:otp_enabled => true, :otp_enabled_on => Time.now)
    end

    def disable_otp!
      update_attributes!(:otp_enabled => false, :otp_enabled_on => nil)
    end

    def generate_otp_challenge!(expires = nil)
      update_attributes!(:otp_session_challenge => SecureRandom.hex,
             :otp_challenge_expires => DateTime.now + (expires || self.class.otp_authentication_timeout))
      otp_session_challenge
    end

    def otp_challenge_valid?
      (otp_challenge_expires.nil? || otp_challenge_expires > Time.now)
    end


    def validate_otp_token(token, recovery = false)
      if recovery
        validate_otp_recovery_token token
      else
        validate_otp_time_token token
      end
    end
    alias_method :valid_otp_token?, :validate_otp_token

    def validate_otp_time_token(token)
      return false if token.blank?
      validate_otp_token_with_drift(token)
    end
    alias_method :valid_otp_time_token?, :validate_otp_time_token

    def next_otp_recovery_tokens(number = self.class.otp_recovery_tokens)
      (otp_recovery_counter..otp_recovery_counter + number).inject({}) do |h, index|
        h[index] = recovery_otp.at(index)
        h
      end
    end

    def validate_otp_recovery_token(token)
      recovery_otp.verify(token, otp_recovery_counter).tap do
        self.otp_recovery_counter += 1
        save!
      end
    end
    alias_method :valid_otp_recovery_token?, :validate_otp_recovery_token



    private

    def validate_otp_token_with_drift(token)

      # should be centered around saved drift
      (-self.class.otp_drift_window..self.class.otp_drift_window).any? {|drift|
        (time_based_otp.verify(token, Time.now.ago(30 * drift))) }
    end

    def generate_otp_persistence_seed
      self.otp_persistence_seed = SecureRandom.hex
    end

    def generate_otp_auth_secret
      self.otp_auth_secret = ROTP::Base32.random_base32
      self.otp_recovery_secret = ROTP::Base32.random_base32
    end

  end
end
