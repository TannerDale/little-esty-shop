# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'welcome#index'
  resources :merchants, only: :index do
    get '/dashboard', controller: :merchants, action: :show, as: 'dashboard'
    resources :items, except: [:delete]
    resources :invoices, only: %i[index show]
    resources :invoice_items, only: [:update]
    resources :discounts
  end

  namespace :admin do
    root to: 'dashboard#index', as: 'dashboard'
    resources :merchants, except: :delete
    resources :invoices, only: %i[index show update]
  end

  resource :users, only: :create
  get '/profile', controller: :users, action: :show
  get '/sign_up', controller: :users, action: :new

  resources :sessions, only: :create
  get '/login', controller: :sessions, action: :new
  delete '/logout', controller: :sessions, action: :destroy
end
