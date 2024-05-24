module DeviseOtpAuthenticatable
  module Controllers
    module PublicHelpers
      extend ActiveSupport::Concern

      def self.generate_helpers!
        Devise.mappings.each do |key, mapping|
          self.define_helpers(mapping)
        end
      end

      def self.define_helpers(mapping) #:nodoc:
        mapping = mapping.name

        class_eval <<-METHODS, __FILE__, __LINE__ + 1
          def ensure_mandatory_#{mapping}_otp!
            resource = current_#{mapping}
            if !devise_controller?
              if otp_mandatory_on?(resource)
                redirect_to edit_#{mapping}_otp_token_path
              end
            end
          end
        METHODS
      end

      def otp_mandatory_on?(resource)
        return true if resource.class.otp_mandatory && !resource.otp_enabled
        return false unless resource.respond_to?(:otp_mandatory)

        resource.otp_mandatory && !resource.otp_enabled
      end

    end
  end
end
