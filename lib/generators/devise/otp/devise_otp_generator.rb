module Devise
  module Otp
    module Generators
      class DeviseOtpGenerator < Rails::Generators::NamedBase

        namespace "devise/otp"

        desc "Add :otp_authenticatable directive in the given model, plus accessors. Also generate migration for ActiveRecord"

        def inject_devise_otp_content
          path = File.join("app","models","#{file_path}.rb")
          inject_into_file(path, "otp_authenticatable, :", :after => "devise :") if File.exists?(path)
        end

        hook_for :orm
      end
    end
  end
end
