require 'generators/devise/views_generator'

module Devise
  module Otp
    module Generators
      class ViewsGenerator < Rails::Generators::Base
        desc 'Copies all Devise OTP views to your application.'

        argument :scope, :required => false, :default => nil,
          :desc => "The scope to copy views to"

        include ::Devise::Generators::ViewPathTemplates
        source_root File.expand_path("../../../../app/views/devise/otp", __FILE__)
        def copy_views
          view_directory :credentials, 'app/views/devise/otp/credentials'
          view_directory :tokens, 'app/views/devise/otp/tokens'
        end
      end
    end
  end
end
