# Devise::OTP

Devise OTP is a two-factors authentication extension for Devise. The second factor is done using an [RFC 6238](https://datatracker.ietf.org/doc/html/rfc6238) Time-Based One-Time Password (TOTP) implemented by the [rotp library](https://github.com/mdp/rotp).

It has the following features:

- Optional and mandatory OTP enforcement
- Setting up trusted browsers for limited access
- Generating QR codes

Some of the compatible token devices are:

* [Google Authenticator](https://code.google.com/p/google-authenticator/)
* [FreeOTP](https://fedorahosted.org/freeotp/)

Device OTP was recently updated to work with Rails 7 and Turbo.

## Sponsor

Devise::OTP development is sponsored by [Business Class](https://businessclasskit.com/) Rails SaaS starter kit. If you don't want to setup OTP yourself for your new project, consider starting one on Business Class.

## Two-factors authentication using OTP

* A shared secret is generated on the server, and stored both on the token device (e.g. the phone) and the server itself.
* The secret is used to generate short numerical tokens that are either time or sequence based.
* Tokens can be generated on a phone without internet connectivity.
* The token provides an additional layer of security against password theft.
* OTP's should always be used as a second factor of authentication(if your phone is lost, you account is still secured with a password)
* Google Authenticator allows you to store multiple OTP secrets and provision those using a QR Code

*Although there's an adjustable drift window, it is important that both the server and the token device (phone) have their clocks set (eg: using NTP).*

## Installation

If you haven't, set up [Devise](https://github.com/heartcombo/devise) first.

To add Devise OTP, add this line to your application's Gemfile:

    gem "devise-otp"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install devise-otp

Run the following generator to add the necessary configuration options to Devise's config file:

    rails g devise_otp:install

After you've created your Devise user models (which is usually done with a `rails g devise MODEL`), set up your Devise OTP additions:

    rails g devise_otp MODEL

Don't forget to migrate:

    rake db:migrate

Add the gem's JavaScript to you `application.js`:

    //= require devise-otp


### Custom views

If you want to customise your views, you can use the following generator to eject the default view files:

    rails g devise_otp:views

By default, the files live within the Devise namespace (`app/views/devise`, but if you want to move them or want to match the Devise configuration, set `config.otp_controller_path` in your initializers. 

### I18n

The install generator also installs an english copy of a Devise OTP i18n file. This can be modified (or used to create other language versions) and is located at: _config/locales/devise.otp.en.yml_

### QR codes

By default, Devise OTP assumes that you use [Sprockets](https://github.com/rails/sprockets) to render assets and so will use the ([qrcode.js](/app/assets/javascripts/qrcode.js)) embeded library to render the QR code.

If you need something more, have a look at [QR codes](/docs/QR_CODES.md) documentation file.

## Configuration

The install generator adds some options to the end of your Devise config file (`config/initializers/devise.rb`):

* `config.otp_mandatory`: OTP is mandatory, users are going to be asked to enroll the next time they sign in, before they can successfully complete the session establishment.
* `config.otp_authentication_timeout`: How long the user has to authenticate with their token. (defaults to `3.minutes`)
* `config.otp_drift_window`: A window which provides allowance for drift between a user's token device clock (and therefore their OTP tokens) and the authentication server's clock. Expressed in minutes centered at the current time. (default: `3`)
* `config.otp_credentials_refresh`: Users that have logged in longer than this time ago, are going to be asked their password (and an OTP challenge, if enabled) before they can see or change their otp informations. (defaults to `15.minutes`)
* `config.otp_recovery_tokens`: Whether the users are given a list of one-time recovery tokens, for emergency access (default: `10`, set to `false` to disable)
* `config.otp_trust_persistence`: The user is allowed to set his browser as "trusted", no more OTP challenges will be asked for that browser, for a limited time. (default: `1.month`, set to false to disable setting the browser as trusted)
* `config.otp_issuer`: The name of the token issuer, to be added to the provisioning url. Display will vary based on token application. (defaults to the Rails application class)
* `config.otp_controller_path`: The view path for Devise OTP controllers. The default being 'devise' to match Devise default installation.

## Authors

The project was originally started by Lele Forzani by forking [devise_google_authenticator](https://github.com/AsteriskLabs/devise_google_authenticator) and still contains some devise_google_authenticator code. It's now maintained by [Josef Strzibny](https://github.com/strzibny/).

Contributions are welcome!

## License

MIT Licensed
