Kurotrade::Application.routes.draw do

  root :to => 'static_pages#index'

  resources :transactions

  resources :portfolios

  resources :groups

  resources :users
  
end
