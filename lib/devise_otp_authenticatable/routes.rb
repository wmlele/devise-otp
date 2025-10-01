module ActionDispatch::Routing
  class Mapper
    protected

    def devise_otp(mapping, controllers)
      namespace :otp, module: :devise_otp do
        resource :token, only: [:show, :edit, :update, :destroy],
          path: mapping.path_names[:token], controller: controllers[:otp_tokens] do
          get :recovery
          post :reset
        end

        if Devise.otp_trust_persistence
          resource :persistence, :only => [:create, :destroy],
            path: mapping.path_names[:persistence], controller: controllers[:otp_persistence] do
            delete :reset
          end
        end

        resource :credential, only: [:show, :update],
          path: mapping.path_names[:credentials], controller: controllers[:otp_credentials] do
          get :refresh, action: "get_refresh"
          put :refresh, action: "set_refresh"
        end
      end
    end
  end
end
