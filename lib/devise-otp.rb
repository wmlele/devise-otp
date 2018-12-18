require "devise/otp/version"

# cherry pick active-support extensions
#require 'active_record/connection_adapters/abstract/schema_definitions'
require 'active_support/core_ext/integer'
require 'active_support/core_ext/string'
require 'active_support/ordered_hash'
require 'active_support/concern'

require 'devise'


module Devise


  #
  #
  #
  mattr_accessor :otp_mandatory
  @@otp_mandatory = false

  #
  #
  #
  mattr_accessor :otp_authentication_timeout
  @@otp_authentication_timeout = 3.minutes

  #
  #
  #
  mattr_accessor :otp_recovery_tokens
  @@otp_recovery_tokens = 10  ## false to disable

  #
  # If the user is given the chance to set his browser as trusted, how long will it stay trusted.
  # set to nil/false to disable the ability to set a device as trusted
  #
  mattr_accessor :otp_trust_persistence
  @@otp_trust_persistence = 30.days

  #
  #
  #
  mattr_accessor :otp_drift_window
  @@otp_drift_window = 3 # in minutes

  #
  # if the user wants to change Otp settings,
  # ask the password (and the token) again if this time has passed since the last
  # time the user has provided valid credentials
  #
  mattr_accessor :otp_credentials_refresh
  @@otp_credentials_refresh = 15.minutes  # or like 15.minutes, false to disable

  #
  # the name of the token issuer
  #
  mattr_accessor :otp_issuer
  @@otp_issuer = Rails.application.class.parent_name

  module Otp
  end
end

module DeviseOtpAuthenticatable

  autoload :Hooks,   'devise_otp_authenticatable/hooks'
  autoload :Mapping, 'devise_otp_authenticatable/mapping'

  module Controllers
    autoload :Helpers,    'devise_otp_authenticatable/controllers/helpers'
    autoload :UrlHelpers, 'devise_otp_authenticatable/controllers/url_helpers'
  end
end


require 'devise_otp_authenticatable/routes'
require 'devise_otp_authenticatable/engine'

Devise.add_module :otp_authenticatable,
                  :controller => :otp_tokens,
                  :model => 'devise_otp_authenticatable/models/otp_authenticatable', :route => :otp
