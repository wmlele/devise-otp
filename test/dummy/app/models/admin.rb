class Admin < PARENT_MODEL_CLASS
  if DEVISE_ORM == :mongoid
    include Mongoid::Document

    ## Database authenticatable
    field :email, type: String, null: false, default: ""
    field :encrypted_password, type: String, null: false, default: ""

    ## Recoverable
    field :reset_password_token, type: String
    field :reset_password_sent_at, type: Time
  end

  devise :otp_authenticatable, :database_authenticatable, :registerable,
    :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  # attr_accessible :otp_enabled, :otp_mandatory, :as => :otp_privileged
  # attr_accessible :email, :password, :password_confirmation, :remember_me

  def self.otp_mandatory
    true
  end

end
