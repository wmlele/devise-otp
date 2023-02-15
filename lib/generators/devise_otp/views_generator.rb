require "generators/devise/views_generator"

module DeviseOtp
  module Generators
    class ViewsGenerator < Rails::Generators::Base
      desc "Copies all Devise OTP views to your application."

      argument :scope, required: false, default: nil,
        desc: "The scope to copy views to"

      include ::Devise::Generators::ViewPathTemplates
      source_root File.expand_path("../../../../app/views", __FILE__)
      def copy_views
        view_directory :devise, "app/views/devise"
      end
    end
  end
end
