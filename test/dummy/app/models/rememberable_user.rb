class RememberableUser < ActiveRecord::Base
  devise :otp_authenticatable, :database_authenticatable, :registerable,
    :trackable, :validatable, :rememberable

  # Setup accessible (or protected) attributes for your model
  # attr_accessible :otp_enabled, :otp_mandatory, :as => :otp_privileged
  # attr_accessible :email, :password, :password_confirmation, :remember_me
end
