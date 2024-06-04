# Changelog

## UNRELEASED

Summary: Add reset token action, and hide/repurpose disable token action

Details:
- Add reset token action to disable OTP, reset token secret, and redirect to otp_tokens#edit to re-enable with new token secret;
- Update disable action to preserve the existing token secret (since the reset action now accomplishes this functionality);
- Hide disable button when mandatory OTP;
- Move disable button to bottom of page;

Breaking Changes (config/locales/en.yml):
- Add:
  - reset\_link
  - successfully\_reset\_otp
- Move/Update
  - disable\_explain > reset\_explain
  - disable\_explain\_warn > reset\_explain\_warn

## UNRELEASED

Fix regression due to warden session scope usage

Details:
- Correct warden session usage for refresh\_credentials hook and helper methods (requires scope to be specified)
- Add Admin model and AdminPosts controller to dummy app for testing;
- Add tests to confirm resolution;

## UNRELEASED

Summary: Move refresh\_credentials functionality to dedicated hook (Refreshable);

Details:
- Add Refreshable hook, and tie into after\_set\_user calback;
- Utilize native warden session for scoping of credentials\_refreshed\_at and refresh\_return\_url properties;
- Remove otp\_refresh\_credentials from sessions hook (no longer needed);

## UNRELEASED

Summary: Move mandatory OTP functionality to the helper layer to ensure that it is enforced throughout application (rather than one time at log in).

Details:
- Add PublicHelpers class, and add to Devise @@helpers variable to generate per-scope ensure\_mandatory\_{scope}\_otp! methods;
- Update order of module definitions and "require" statements in devise-otp.rb (required for adding DeviseOtpAuthenticable PublicHelpers to Devise @@helpers variable);

Breaking Changes:
- Requires adding "ensure\_mandatory\_{scope}\_otp! to controllers;

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
