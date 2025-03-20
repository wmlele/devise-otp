require "devise-otp/version"

# cherry pick active-support extensions
# require 'active_record/connection_adapters/abstract/schema_definitions'
require "active_support/core_ext/integer"
require "active_support/core_ext/string"
require "active_support/ordered_hash"
require "active_support/concern"

require "devise"

#
# define DeviseOtpAuthenticatable module, and autoload hooks and helpers
#
module DeviseOtpAuthenticatable
  module Controllers
    autoload :Helpers, "devise_otp_authenticatable/controllers/helpers"
    autoload :UrlHelpers, "devise_otp_authenticatable/controllers/url_helpers"
    autoload :PublicHelpers, "devise_otp_authenticatable/controllers/public_helpers"
  end
end

require "devise_otp_authenticatable/routes"
require "devise_otp_authenticatable/engine"
require "devise_otp_authenticatable/hooks/refreshable"

#
# update Devise module with additions needed for DeviseOtpAuthenticatable
#
module Devise
  mattr_accessor :otp_mandatory
  @@otp_mandatory = false

  mattr_accessor :otp_authentication_timeout
  @@otp_authentication_timeout = 3.minutes

  mattr_accessor :otp_recovery_tokens
  @@otp_recovery_tokens = 10  ## false to disable

  #
  # If the user is given the chance to set his browser as trusted, how long will it stay trusted.
  # set to nil/false to disable the ability to set a device as trusted
  #
  mattr_accessor :otp_trust_persistence
  @@otp_trust_persistence = 30.days

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
  @@otp_issuer = Rails.application.class.module_parent_name

  #
  # custom view path
  #
  mattr_accessor :otp_controller_path
  @@otp_controller_path = "devise"

  #
  # request recovery token after n failed otp attempts
  #
  mattr_accessor :otp_max_failed_attempts
  @@otp_max_failed_attempts = 10

  #
  # request recevery token if timeout hasn't passed since last failed attempt
  #
  mattr_accessor :otp_recovery_timeout
  @@otp_recovery_timeout = 30.minutes # 0 to disable

  #
  # email otp token if valid for
  #
  mattr_accessor :otp_by_email_code_valid_for
  @@otp_by_email_code_valid_for = 5.minutes

  #
  # add PublicHelpers to helpers class variable to ensure that per-mapping helpers are present.
  # this integrates with the "define_helpers," which is run when adding each mapping in the Devise gem (lib/devise.rb#541)
  #
  @@helpers << DeviseOtpAuthenticatable::Controllers::PublicHelpers

  module Otp
  end

end

Devise.add_module :otp_authenticatable,
  controller: :tokens,
  model: "devise_otp_authenticatable/models/otp_authenticatable", route: :otp

#
# add PublicHelpers after adding Devise module to ensure that per-mapping routes from above are included
#
ActiveSupport.on_load(:action_controller) do
  include DeviseOtpAuthenticatable::Controllers::PublicHelpers
end
