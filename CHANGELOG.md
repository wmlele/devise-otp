# Changelog

## Unreleased

- Upgrade gemspec to support Rails v7.2

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
