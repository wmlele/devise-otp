require 'generators/devise/views_generator'

module DeviseOtp
  module Generators
    class ViewsGenerator < Rails::Generators::Base
      desc 'Copies all Devise OTP views to your application.'

      argument :scope, :required => false, :default => nil,
                       :desc => "The scope to copy views to"

      include ::Devise::Generators::ViewPathTemplates
      source_root File.expand_path("../../../../app/views/devise_otp", __FILE__)
      def copy_views
        view_directory :credentials, 'app/views/devise_otp/credentials'
        view_directory :tokens, 'app/views/devise_otp/tokens'
      end
    end
  end
end
