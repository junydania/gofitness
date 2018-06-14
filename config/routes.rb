Rails.application.routes.draw do
  
  devise_for :members, :controllers => {:registrations => "admin/members"}
  devise_for :users,  :controllers => {:registrations => "admin/users"}

  devise_scope :user do
    get 'users' => 'admin/users#index', as: :users
    get 'user/:id' => 'admin/users#show', as: :user_profile
  end

  devise_scope :user do
    get 'members' => 'admin/members#index', as: :members
    # get 'user/:id' => 'admin/users#show', as: :user_profile
  end


  namespace :admin do
    resources :subscription_plans
    resources :features
    resources :fitness_goals
    resources :payment_methods
    resources :member_steps
  end
  
  root 'welcome#index'

  get 'welcome/index'

end
