Kurotrade::Application.routes.draw do

  root :to => 'static_pages#index'
  get '/balances', :to => 'static_pages#balance_exp'
  get '/dashboard', :to => 'static_pages#mock_dashboard'

  resources :transactions
  match '/transactions/file_upload', :to => 'transactions#scottrade_csv_parser', :as => 'transactions_upload'

  resources :portfolios

  resources :groups

  resources :users
  
end
