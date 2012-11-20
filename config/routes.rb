Kurotrade::Application.routes.draw do

  root :to => 'static_pages#index'

  resources :transactions
  match '/transactions/file_upload', :to => 'transactions#scottrade_csv_parser', :as => 'transactions_upload'

  resources :portfolios

  resources :groups

  resources :users
  
end
