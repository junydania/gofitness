Rails.application.routes.draw do
  
  require 'sidekiq/web'
  require 'sidekiq/cron/web'

  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end

  mount Plutus::Engine => "/plutus", :as => "plutus"
  
  # devise_for :members, :controllers => {:registrations => "admin/members"}
  devise_for :users,  :controllers => {:registrations => "admin/users"}
  

  devise_scope :user do
    get    'users' => 'admin/users#index', as: :users
    get    'user/:id' => 'admin/users#show', as: :user_profile
    get    'staff_tracking' => 'admin/users#staff_tracking', as: :staff_tracking
    get    'users/:id/edit' => 'admin/users#edit', as: :edit_user
    patch  'users/:id' =>               'admin/users#update'
    get    'change_role/:id/edit'  =>  'admin/users#change_role', as: :update_staff_role
    patch  'change_role/:id'  =>     'admin/users#update_role'
  end

  get    'members' => 'admin/members#index', as: :members
  get    'member/:id' => 'admin/members#show', as: :member_profile
  get    'renew_member/:id' => 'admin/members#renew_membership', as: :renew_member
  get    'unsubscribe_member/:id' => 'admin/members#unsubscribe_membership', as: :unsubscribe_member
  put    'cash_renewal/:id' => 'admin/members#cash_renewal', as: :cash_renewal
  put    'pos_renewal/:id' => 'admin/members#pos_renewal', as: :pos_renewal
  post   'paystack_renewal' => 'admin/members#paystack_renewal', as: :paystack_renewal
  post   'pause_subscription' => 'admin/members#pause_subscription', as: :pause_subscription
  post   'cancel_pause' => 'admin/members#cancel_pause', as: :cancel_pause
  get    'fund_wallet/:id' => 'admin/wallets#fund_page', as: :wallet_fund_page
  post   'paystack_wallet_fund' => 'admin/wallets#paystack_wallet_fund', as: :paystack_wallet_fund
  post   'wallet_renewal' => 'admin/members#wallet_renewal', as: :wallet_renewal
  put    'pos_wallet_fund/:id' => 'admin/wallets#pos_wallet_fund', as: :pos_wallet_fund
  put    'cash_wallet_fund/:id' => 'admin/wallets#cash_wallet_fund', as: :cash_wallet_fund
  get    'subscription_history/:id' => 'admin/historicals#subscription_history', as: :member_subscription_history
  get    'loyalty_history/:id' => 'admin/historicals#loyalty_history', as: :member_loyalty_history
  get    'wallet_history/:id' => 'admin/historicals#wallet_history', as: :member_wallet_history
  get    'attendance_history/:id' => 'admin/historicals#attendance_history', as: :member_attendance_history
  get    'members/:id/edit' => 'admin/members#edit', as: :edit_member
  patch  'members/:id' => 'admin/members#update'
  get    'members/new' => 'admin/members#new', as: :new_member
  post   'members'     => 'admin/members#create'
  get    'members/:id'  => 'admin/members#image_capture', as: :image_page
  post   'members/upload_image' => 'admin/members#upload_image', as: :image_upload
  get    'members/activate_account/:id' => 'admin/members#activate_account', as: :activate_account
  patch  'members/activate_account/:id' => 'admin/members#complete_activation'
  get    'members/change_plan/:id' => 'admin/members#change_plan', as: :change_plan
  post   'send_paystack_invoice' => 'admin/members#send_paystack_invoice', as: :send_paystack_invoice
  patch  'members/change_plan/:id' => 'admin/members#change_plan_update'


  namespace :admin do
    resources :attendance_records, only: [:index]
    resources :subscription_plans
    resources :features
    resources :fitness_goals
    resources :payment_methods
    resources :member_steps
    resources :health_conditions
    post  'paystack_subscribe' => 'member_steps#paystack_subscribe', as: :paystack_subscription
    post  'upload_image' => 'member_steps#upload_image', as: :image_upload
    post  'member_check_in' => 'attendance_records#member_check_in', as: :member_check_in
    get   'developer_test_mail_form' => 'developer_test#get_mail_form', as: :get_mail_form
    patch 'developer_test_email' => 'developer_test#send_mail', as: :developer_send_mail
    post  'check_recurring' => 'subscription_plans#check_recurring', as: :check_recurring
    post  'check_selected_plan' => 'subscription_plans#check_selected_plan', as: :check_selected_plan
    resources :loyalties
    resources :one_off_revenues
  end

  post '/:paystack_webhook' => 'webhooks#receive', as: :receive_webhooks

  root 'welcome#index'

  get 'welcome/index'

end

