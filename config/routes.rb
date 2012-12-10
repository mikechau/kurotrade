Kurotrade::Application.routes.draw do

  root :to => 'static_pages#index'

  #resource :session, :only => [:new, :create, :destroy]

  get "login" => 'sessions#new', as: :login
  post "session" => 'sessions#create' 
  get "logout" => 'sessions#destroy', as: :logout

  get '/balances', :to => 'static_pages#balance_exp'
  get '/test', :to => 'static_pages#testing'
  get '/dashboard', :to => 'static_pages#mock_dashboard', as: :dashboard
  get '/about', :to => 'static_pages#about', as: :about
  get '/contact', :to => 'static_pages#contact', as: :contact

  resources :transactions
  match '/transactions/file_upload', :to => 'transactions#scottrade_csv_parser', :as => 'transactions_upload'

  resources :portfolios

  resources :groups

  resources :users
  
end
