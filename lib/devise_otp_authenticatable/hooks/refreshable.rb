# After each sign in, update credentials refreshed at time
Warden::Manager.after_set_user except: :fetch do |record, warden, options|
  if record.class.otp_credentials_refresh && record.respond_to?(:credentials_refreshed_at) && warden.authenticated?(options[:scope])
    record.update(:credentials_refreshed_at => DateTime.now)
  end
end

