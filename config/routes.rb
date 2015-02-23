Rails.application.routes.draw do

  get 'password_resets/new'

  use_doorkeeper

  get "/404" => "errors#not_found"
  get "/500" => "errors#exception"

  api_version(module: "V0", path: {value: "v0"}, default: true) do
    match "add" => "readings#add", via: [:get, :post, :patch, :put]
    resources :readings, only: [:create, :index]
    resources :users, only: [:index, :show, :create]
    resources :sensors
    resources :components
    resources :kits
    resources :password_resets, only: [:create, :update]
    resources :me, only: [:index] do
      patch '/' => 'me#update', on: :collection
    end
    resources :devices do
      resources :readings, only: :index
      get 'world_map', on: :collection
    end
    root to: 'static#home'
  end
  root to: 'v0/static#home'

end
