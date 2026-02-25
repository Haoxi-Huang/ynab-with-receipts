Rails.application.routes.draw do
  get "up", to: proc { [200, {}, ["OK"]] }

  root "receipts#index"

  get  "/login",  to: "sessions#new",     as: :login
  delete "/logout", to: "sessions#destroy", as: :logout

  get  "/auth/:provider/callback", to: "sessions#create"
  get  "/auth/failure",            to: "sessions#failure"

  resources :receipts do
    resource :match, only: [:new, :create, :destroy]
  end

  get "/ynab_transactions/search", to: "ynab_transactions#search", as: :search_ynab_transactions
end
