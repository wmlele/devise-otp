# frozen_string_literal: true

require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    # Default strategy for signing in a user, based on their email and password in the database.
    class DatabaseAuthenticatable < Authenticatable
      def authenticate!
        resource  = password.present? && mapping.to.find_for_database_authentication(authentication_hash)
        hashed = false

        if validate(resource){ hashed = true; resource.valid_password?(password) }
          if otp_challenge_required_on?(resource)
            # Redirect to challenge
            challenge = resource.generate_otp_challenge!
            redirect!(otp_challenge_url, {:challenge => challenge})
          else
            # Sign in user as usual
            remember_me(resource)
            resource.after_database_authentication
            success!(resource)
          end
        end

        # In paranoid mode, hash the password even when a resource doesn't exist for the given authentication key.
        # This is necessary to prevent enumeration attacks - e.g. the request is faster when a resource doesn't
        # exist in the database if the password hashing algorithm is not called.
        mapping.to.new.password = password if !hashed && Devise.paranoid
        unless resource
          Devise.paranoid ? fail(:invalid) : fail(:not_found_in_database)
        end
      end

      private

      #
      # resource should be challenged for otp
      #
      def otp_challenge_required_on?(resource)
        resource.respond_to?(:otp_enabled?) && resource.otp_enabled?
      end

      def otp_challenge_url
        if Rails.env.development? || Rails.env.test?
          host = "#{request.host}:#{request.port}"
        else
          host = "#{request.host}"
        end

        path_fragments = ["otp", mapping.path_names[:credentials]]
        if mapping.fullpath == "/"
          path = mapping.fullpath + path_fragments.join("/")
        else
          path = path_fragments.prepend(mapping.fullpath).join("/")
        end

        request.protocol + host + path
      end
    end
  end
end

Warden::Strategies.add(:database_authenticatable, Devise::Strategies::DatabaseAuthenticatable)
