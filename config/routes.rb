Rails.application.routes.draw do
  devise_for :users

  root to: "pages#home"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get '/routes', to: 'routes#index', as: :myroutes
  get '/routes/:id/update_title', to: 'routes#updateroutetitle', as: :updateroutetitle
  get '/routes/:id/update_city', to: 'routes#updateroutecity', as: :updateroutecity
  get '/maptest', to: 'pages#directionstestpage', as: :directionstestpage
  get '/routes/:id/save', to: 'routes#save', as: :save_route
  get '/routes/:id/update_mode_walking', to: 'routes#update_mode_walking', as: :update_mode_walking
  get '/routes/:id/update_mode_cycling', to: 'routes#update_mode_cycling', as: :update_mode_cycling
  get '/routes/:id/update_mode_driving', to: 'routes#update_mode_driving', as: :update_mode_driving

  # Defines the root path route ("/")
  resources :routes do
    member do
      patch :move
      patch :noroute
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
