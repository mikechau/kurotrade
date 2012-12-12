Kurotrade::Application.routes.draw do

  root :to => 'static_pages#index'

  #resource :session, :only => [:new, :create, :destroy]

  get "login" => 'sessions#new', as: :login
  post "session" => 'sessions#create' 
  get "logout" => 'sessions#destroy', as: :logout

  #get '/balances', :to => 'static_pages#balance_exp'
  match '/boarding/welcome', :to => 'static_pages#welcome', as: :welcome
  match '/boarding/partner', :to => 'static_pages#new_partner', as: :boarding_partner
  match '/boarding/individual', :to => 'static_pages#new_individual', as: :boarding_individual

  get '/dashboard', :to => 'static_pages#mock_dashboard', as: :dashboard
  get '/about', :to => 'static_pages#about', as: :about
  get '/contact', :to => 'static_pages#contact', as: :contact

  resources :transactions
  match '/transactions/file_upload', :to => 'transactions#scottrade_csv_parser', :as => 'transactions_upload'

  resources :portfolios

  resources :groups
  match '/individual/new', :to => 'groups#new', :as => 'new_individual'

  resources :users
  
end
