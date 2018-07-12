Rails.application.routes.draw do
  
  devise_for :members, :controllers => {:registrations => "admin/members"}
  devise_for :users,  :controllers => {:registrations => "admin/users"}

  devise_scope :user do
    get 'users' => 'admin/users#index', as: :users
    get 'user/:id' => 'admin/users#show', as: :user_profile
  end

  devise_scope :member do
    get 'members' => 'admin/members#index', as: :members
    get 'member/:id' => 'admin/members#show', as: :member_profile
    get 'renew_member/:id' => 'admin/members#renew_membership', as: :renew_member
    put 'cash_renewal/:id' => 'admin/members#cash_renewal', as: :cash_renewal
    put 'pos_renewal/:id' => 'admin/members#pos_renewal', as: :pos_renewal
    post 'paystack_renewal' => 'admin/members#paystack_renewal', as: :paystack_renewal
  end

  namespace :admin do
    resources :subscription_plans
    resources :features
    resources :fitness_goals
    resources :payment_methods
    resources :member_steps
    resources :health_conditions
    post 'paystack_subscribe' => 'member_steps#paystack_subscribe', as: :paystack_subscription
    post 'upload_image' => 'member_steps#upload_image', as: :image_upload
    resources :loyalties
  end
  
  root 'welcome#index'

  get 'welcome/index'

end

