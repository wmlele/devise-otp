Dummy::Application.routes.draw do
  devise_for :admins
  devise_for :users

  devise_for :lockable_users
  devise_for :non_otp_users
  devise_for :rememberable_users

  resources :posts
  resources :admin_posts
  resources :non_otp_posts

  root to: "base#home"
end
