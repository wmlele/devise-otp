# Changelog

## UNRELEASED

Use dedicated devise hook for refreshing credentials.

Details:
- Add dedicated hook and column for refresh_credential functionality;
- Move/simplify check/redirection to refresh_credentials! helper method;
- Remove "refresh_otp_credentials" method from session hook (no longer needed);
- Remove comments regarding cookie/persistence scope (no longer needed);

Breaking Changes:
- Requires adding the credentials_refreshed_at field to the database;

## UNRELEASED

Summary:
- Require confirmation token before enabling Two Factor Authentication (2FA) to ensure that user has added OTP token properly to their device
- Update system to populate OTP secrets as needed

Details:
- Add "edit" action with Confirmation Token for enabling 2FA to otp_tokens controller
- Make enabling of 2FA in update action conditional on valid Confirmation Token
- Repurpose "show" view for display of OTP status and info (no form)

- Update otp_tokens#edit to populate OTP secrets (rather than assuming they are populated via callbacks in OTPDeviseAuthenticatable module)
- Repurpose otp_tokens#destroy to disable 2FA and clear OTP secrets (rather than resetting them)

- Remove OtpAuthenticatable callbacks for setting OTP credentials on create action (no longer needed)
- Replace OtpAuthenticatable "reset_otp_credentials" methods with "clear_otp_fields!" method;

Changes to Locales:
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

## 0.4.0

Breaking changes:

- rename `Devise::Otp` to `Devise::OTP`
- change `credentials` directory to `otp_credentials`
- change `tokens` directory to `otp_tokens`

Other improvements:

- Fix file permissions

## 0.3.0

A long awaited update bringing Devise::OTP from the dead!
