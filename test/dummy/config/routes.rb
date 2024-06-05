Dummy::Application.routes.draw do
  devise_for :users
  devise_for :admins

  resources :posts
  resources :admin_posts

  root to: "posts#index"
end
