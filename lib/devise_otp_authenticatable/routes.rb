module ActionDispatch::Routing
  class Mapper


    protected
    #########

    def devise_otp(mapping, controllers)

      namespace :otp, module: 'devise/otp' do
        resource :token, :only => [:show, :update, :destroy],
          :path => mapping.path_names[:token], :controller => controllers[:otp_tokens] do

          if ::Devise.otp_trust_persistence
            get  :persistence, :action => 'get_persistence'
            post :persistence, :action => 'clear_persistence'
            delete :persistence, :action => 'delete_persistence'
          end

          get  :recovery
        end

        resource :credential, :only => [:show, :update],
          :path => mapping.path_names[:credentials], :controller => controllers[:otp_credentials] do

          get  :refresh, :action => 'get_refresh'
          put :refresh, :action => 'set_refresh'
        end
      end
    end
  end
end
