Rails.application.routes.draw do
  devise_for :users

  root to: "pages#home"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get '/routes', to: 'routes#index', as: :myroutes
  get '/routes/public', to: 'routes#index_public', as: :public_routes
  get '/admin', to: 'pages#admin', as: :admin
  get '/admin/export', to: 'pages#export', as: :export

  get '/routes/:id/update_title', to: 'routes#updateroutetitle', as: :updateroutetitle
  get '/routes/:id/update_city', to: 'routes#updateroutecity', as: :updateroutecity

  # get '/routes/:id/save', to: 'routes#save', as: :save_route

  get '/routes/:id/update_mode_walking', to: 'routes#update_mode_walking', as: :update_mode_walking
  get '/routes/:id/update_mode_cycling', to: 'routes#update_mode_cycling', as: :update_mode_cycling
  get '/routes/:id/update_mode_driving', to: 'routes#update_mode_driving', as: :update_mode_driving

  patch '/apicalls/geocoding', to: 'api_calls#add_geocoding'
  patch '/apicalls/maploads', to: 'api_calls#add_maploads'
  patch '/apicalls/directions', to: 'api_calls#add_directions'

  # Defines the root path route ("/")
  resources :routes do
    member do
      patch :move
      get :save
      patch :share_route
      patch :stop_sharing_route
    end
    resources :destinations, only: [:create]

    resources :route_destinations do
      member do
        patch :move
      end
    end
  end
  resources :route_destinations, only: [:create, :destroy]
end
