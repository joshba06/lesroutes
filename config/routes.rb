Rails.application.routes.draw do
  devise_for :users

  root to: "pages#home"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get '/routes', to: 'routes#index', as: :myroutes
  get '/maptest', to: 'pages#directionstestpage', as: :directionstestpage

  # Defines the root path route ("/")
  # root "articles#index"
  resources :routes do
    member do
      patch :move
    end
    resources :destinations, except: [:destroy]
    resources :route_destinations do
      member do
        patch :move
      end
    end
  end
  resources :destinations, only: [:destroy]
end
