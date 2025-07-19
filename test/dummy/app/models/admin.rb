class Admin < ActiveRecord::Base
  devise :otp_authenticatable, :database_authenticatable, :registerable,
    :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  # attr_accessible :otp_enabled, :otp_mandatory, :as => :otp_privileged
  # attr_accessible :email, :password, :password_confirmation, :remember_me

  def self.otp_mandatory
    true
  end

end
