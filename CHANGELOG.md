# Changelog

## UNRELEASED

Summary:
- Require confirmation token before enabling Two Factor Authentication (2FA) to ensure that user has added OTP token properly to their device
- Update system to populate OTP secrets only as needed

Changes:
- Add "edit" action with Confirmation Token for enabling 2FA to otp_tokens controller
- Make enabling of 2FA in update action conditional on valid Confirmation Token
- Repurpose "show" view for display of OTP status and info (no form)

- Update otp_tokens#edit to populate OTP secrets (rather than assuming they are populated via callbacks in OTPDeviseAuthenticatable module)
- Repurpose otp_tokens#destroy to disable 2FA and clear OTP secrets (rather than resetting them)

- Remove callbacks for setting OTP credentials on create action (no longer needed)
- Replace "reset_otp_credentials" methods with "clear_otp_fields!" method;

Changes to Locales:
- Move OTP explanation and form related values to devise.otp.edit_otp_tokens scope
- Rename devise.otp.token_secret.reset_\* values to ...disable_\*
- Rename "successfully_reset_creds" value to "successfully_disabled_otp"
- Add "enable_link" and "could_not_confirm" to otp_tokens scope
- Add "lead_in", "step1", "step2", and "otp_token" to edit_otp_tokens scope

## 0.4.0

Breaking changes:

- rename `Devise::Otp` to `Devise::OTP`
- change `credentials` directory to `otp_credentials`
- change `tokens` directory to `otp_tokens`

Other improvements:

- Fix file permissions

## 0.3.0

A long awaited update bringing Devise::OTP from the dead!
