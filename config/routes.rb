Rails.application.routes.draw do
  
  devise_for :users,  :controllers => {:registrations => "admin/users"}

  devise_scope :user do
    get 'users' => 'admin/users#index', as: :users
    get 'user/:id' => 'admin/users#show', as: :user_profile
  end

  namespace :admin do
    resources :subscription_plans
    resources :features
  end

  root 'welcome#index'
    
  get 'welcome/index'

end
