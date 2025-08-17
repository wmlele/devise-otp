# Changelog

## Unreleased
Bug fixes:
- Fixed an issue where Turbo/Hotwire enabled applications return a JS error for failed OTP authentication;

Improvements:
- Add support for Lockable strategy to OTP credentials form;
- Use locales for "Enabled/Disabled" status;
- Fix spelling, spacing, and grammatical issues in the default locales file;

Code Quality:
- Use built-in functionality from rotp gem for handling the TOTP drift window;
- Use standard URL Helpers in database\_authenticatable;
- Refactor code for otp\_issuer method;
- Cleanup Ruby syntax in ERB views;
- Add Timecop for testing time based functionality;
- Add Rubocop and ERB Lint;

## 1.1.0

Bug fixes:
- Update refreshable hook to ensure that user models without Devise OTP can still sign in
- Add tests for non-OTP user models to confirm resolution

Improvements:
- Remove references to MongoDB from test suite
- Standardize test application's database configuration
- Add Development Instructions to README

## 1.0.1
- Add support for Ruby 3.4
- Set minimum Ruby version to 3.2
- Set miminum Rails version to 7.1
- Add MIT license type to gemspec
- Correct Devise spelling error in README

## 1.0.0
- Add support for Rails 8
- Generate QR Codes as SVG
- Fix Issue with Invalid Token Message
- Simplify OTP Credentials Controller
- Expand Flash Message Tests
- Use Appraisal gem to against older Rails versions

## 0.8.0
- Add support for Rails 7.2 and drop support for Rails 6.1
- Fix issue with scoped redirects for non-default resources
- Add migration version numbers
- Cleanup old docs

## 0.7.1
- Fix host and port for 3rd-party tests

## 0.7.0

Breaking changes:

- Require confirmation token before enabling Two Factor Authentication (2FA) to ensure that user has added OTP token properly to their device
- Update DeviseAuthenticatable to redirect user (rather than login user) when OTP is enabled
- Remove OtpAuthenticatable callbacks for setting OTP credentials on create action (no longer needed)
- Replace OtpAuthenticatable "reset_otp_credentials" methods with "clear_otp_fields!" method
- Update otp_tokens#edit to populate OTP secrets (rather than assuming they are populated via callbacks in OTPDeviseAuthenticatable module)
- Repurpose otp_tokens#destroy to disable 2FA and clear OTP secrets (rather than resetting them)
- Add reset token action and hide/repurpose disable token action
- Update disable action to preserve the existing token secret
- Hide button for mandatory OTP
- Add Refreshable hook, and tie into after\_set\_user calback
- Utilize native warden session for scoping of credentials\_refreshed\_at and refresh\_return\_url properties
- Require adding "ensure\_mandatory\_{scope}\_otp! to controllers for mandatory OTP
- Update locales to support the new workflow

### Upgrading

Regenerate your views with `rails g devise_otp:views` and update locales.

Changes to locales:

- Remove:
  - otp_tokens.enable_request
  - otp_tokens.status
  - otp_tokens.submit
- Add to otp_tokens scope:
  - enable_link
- Move/rename devise.otp.token_secret.reset_\* values to devise.otp.otp_tokens.disable_\* (for consistency with "enable_link")
  - disable_link
  - disable_explain
  - disable_explain_warn
- Add to new edit_otp_token scope:
  - title
  - lead_in
  - step1
  - step2
  - confirmation_code
  - submit
- Move "explain" to new edit_otp_token scope
- Add devise.otp.otp_tokens.could_not_confirm
- Rename "successfully_reset_creds" to "successfully_disabled_otp"

You can grab the full locale file [here](https://github.com/wmlele/devise-otp/blob/master/config/locales/en.yml).

## 0.6.0

Improvements:

- support rails 6.1 by @cotcomsol in #67

Fixes:

- mandatory otp fix by @cotcomsol in #68
- remove success message by @strzibny in #69
