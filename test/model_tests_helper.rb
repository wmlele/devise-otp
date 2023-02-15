class ActiveSupport::TestCase
  #
  # Helpers for creating new users
  #
  def unique_identity
    @@unique_identity_count ||= 0
    @@unique_identity_count += 1
    "user-#{@@unique_identity_count}@mail.invalid"
  end

  def valid_attributes(attributes = {})
    {email: unique_identity,
     password: "12345678",
     password_confirmation: "12345678"}.update(attributes)
  end

  def new_user(attributes = {})
    User.new(valid_attributes(attributes)).save
  end
end
