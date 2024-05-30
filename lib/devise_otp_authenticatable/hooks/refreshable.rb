# After each sign in, update credentials refreshed at time
Warden::Manager.after_set_user except: :fetch do |record, warden, options|
  warden.session["credentials_refreshed_at"] = (Time.now + record.class.otp_credentials_refresh)
end

