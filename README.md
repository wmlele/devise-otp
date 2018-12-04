# Devise::Otp
[![Build Status](https://travis-ci.org/wmlele/devise-otp.png?branch=master)](https://travis-ci.org/wmlele/devise-otp)

Devise OTP implements two-factors authentication for Devise, using an rfc6238 compatible Time-Based One-Time Password Algorithm.
It uses the [rotp library](https://github.com/mdp/rotp) for generation and verification of codes.

**If you are upgrading from version 0.1.x, you will need to regenerate your views.**

It currently has the following features:

* Url based provisioning of token devices, compatible with **Google Authenticator**.
* Browsers can be set as 'trusted' for a limited time. During that time no OTP challenge is asked again when logging from that browser (but normal login will).
* Two factors authentication can be **optional** at user discretion, **recommended** (it nags the user on every sign-in) or **mandatory** (users must enroll OTP after signing-in next time, before they can navigate the site). The settings is global, or per-user. ( **incomplete**, see below)
* Optionally, users can obtain a list of HOTP recovery tokens to be used for emergency log-in in case the token device is lost or unavailable.

Compatible token devices are:

* [Google Authenticator](https://code.google.com/p/google-authenticator/)
* [FreeOTP](https://fedorahosted.org/freeotp/)

## Quick overview of Two Factors Authentication, using OTPs.

* A shared secret is generated on the server, and stored both on the token device (ie: the phone) and the server itself.
* The secret is used to generate short numerical tokens that are either time or sequence based.
* Tokens can be generated on a phone without internet connectivity.
* The token provides an additional layer of security against password theft.
* OTP's should always be used as a second factor of authentication(if your phone is lost, you account is still secured with a password)
* Google Authenticator allows you to store multiple OTP secrets and provision those using a QR Code

Although there's an adjustable drift window, it is important that both the server and the token device (phone) have their clocks set (eg: using NTP).


## Installation

Add this line to your application's Gemfile:

    gem 'devise'
    gem 'devise-otp'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install devise-otp


### Devise Installation

To setup Devise, you need to do the following (but refer to https://github.com/plataformatec/devise for more information)

Install Devise:

    rails g devise:install

Setup the User or Admin model

    rails g devise MODEL

Configure your app for authorisation, edit your Controller and add this before_filter:

    before_action :authenticate_user!

Make sure your "root" route is configured in config/routes.rb

### Automatic Installation

Run the following generator to add the necessary configuration options to Devise's config file:

    rails g devise_otp:install

After you've created your Devise user models (which is usually done with a "rails g devise MODEL"), set up your Devise OTP additions:

    rails g devise_otp MODEL

Don't forget to migrate:

    rake db:migrate

Add the gem's javascript to you application.js

    //= require devise-otp



### Custom Views

If you want to customise your views (which you likely will want to), you can use the generator:

    rails g devise_otp:views

### I18n

The install generator also installs an english copy of a Devise OTP i18n file. This can be modified (or used to create other language versions) and is located at: _config/locales/devise.otp.en.yml_


## Usage

With this extension enabled, the following is expected behaviour:

* Users may go to _/MODEL/otp/token_ and enable their OTP state, they might be asked to provide their password again (and OTP token, if it's enabled)
* Once enabled they're shown an alphanumeric code (for manual provisioning) and a QR code, for automatic provisioning of their authetication device (for instance, Google Authenticator)
* If config.otp_mandatory or model_instance.otp_mandatory, users will be required to enable, and provision, next time they successfully sign-in.


### Configuration Options

The install generator adds some options to the end of your Devise config file (config/initializers/devise.rb)

* `config.otp_mandatory` - OTP is mandatory, users are going to be asked to enroll the next time they sign in, before they can successfully complete the session establishment.
* `config.otp_authentication_timeout` - how long the user has to authenticate with their token. (defaults to `3.minutes`)
* `config.otp_drift_window` - a window which provides allowance for drift between a user's token device clock (and therefore their OTP tokens) and the authentication server's clock. Expressed in minutes centered at the current time. (default: `3`)
* `config.otp_credentials_refresh` - Users that have logged in longer than this time ago, are going to be asked their password (and an OTP challenge, if enabled) before they can see or change their otp informations. (defaults to `15.minutes`)
* `config.otp_recovery_tokens` - Whether the users are given a list of one-time recovery tokens, for emergency access (default: `10`, set to `false` to disable)
* `config.otp_trust_persistence` - The user is allowed to set his browser as "trusted", no more OTP challenges will be asked for that browser, for a limited time. (default: `1.month`, set to false to disable setting the browser as trusted)
* `config.otp_issuer` - The name of the token issuer, to be added to the provisioning url. Display will vary based on token application. (defaults to the Rails application class)

## Todo

* 2D barcodes for provisioning are currently produced with the google charts api. You can, of course, use your own source in the template, but I am looking for a solution with no external dependencies (feedback welcome).
* **recommended** mode (nag the user each time) is not fully implemented. Right now you can make 2FA mandatory, or leave it to the user.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Thanks

I started this extension by forking [devise_google_authenticator](https://github.com/AsteriskLabs/devise_google_authenticator), and this project still contains some chunk of code from it, esp. in the tests and generators.
At some point, my design goals were significantly diverging, so I refactored most of its code. Still, I want to thank the original author for his relevant contribution.

## License

MIT Licensed
