module DeviseOtpAuthenticatable
  module Controllers
    module PublicHelpers
      extend ActiveSupport::Concern

      def self.define_helpers(mapping) #:nodoc:
        mapping = mapping.name

        class_eval <<-TEST_METHOD, __FILE__, __LINE__ + 1
          def test_#{mapping}_method
            raise "Test method for #{mapping} included successfully."
          end
        TEST_METHOD

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

        ActiveSupport.on_load(:action_controller) do
          if respond_to?(:helper_method)
            helper_method "ensure_mandatory_#{mapping}_otp!"
          end
        end
      end

      def test_method
        raise "Test method included successfully."
      end

      def otp_mandatory_on?(resource)
        return true if resource.class.otp_mandatory && !resource.otp_enabled
        return false unless resource.respond_to?(:otp_mandatory)

        resource.otp_mandatory && !resource.otp_enabled
      end

    end
  end
end
