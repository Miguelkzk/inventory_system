Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  # Ruta para listar todos los artículos y crear un nuevo artículo
  resources :articles do
    collection do
      get :inventory_models
      get :attributes_description
      get :find_by_code
    end
    member do
      get :optimal_lot # GET /articles/:id/optimal_lot?provider_id=:id
      get :historical_demand
      post :predict_demand
      get :providers
      get :cgi
      get :active_purchase_orders
    end
  end

  resources :providers do
    collection do
      get :attributes_description
    end
  end

  resources :sales do
    collection do
      get :attributes_description
    end
  end

  resources :purchase_orders do
    collection do
      get :attributes_description
    end
  end

  resources :historical_demands, only: :create
end
