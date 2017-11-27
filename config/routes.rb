Rails.application.routes.draw do
  use_doorkeeper
  authenticate :user do
    resources :files, controller: 'documents', as: 'documents'
    resources :folders
  end

  get 'home/index'
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  devise_scope :user do
    get 'sign_in', :to => 'devise/sessions#new', :as => :new_user_session
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :files, controller: 'documents', as: 'documents'
      resources :folders
    end
  end

  root to: 'home#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
