Rails.application.routes.draw do
  
  devise_for :users,  :controllers => {:registrations => "admin/users"}

  devise_scope :user do
    get 'users' => 'admin/users#index', as: :users
  end

  root 'welcome#index'
    
  get 'welcome/index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
