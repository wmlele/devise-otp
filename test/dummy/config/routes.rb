Dummy::Application.routes.draw do
  devise_for :admins
  devise_for :users

  resources :posts
  resources :admin_posts

  root to: "base#home"
end
