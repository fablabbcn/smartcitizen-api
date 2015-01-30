Rails.application.routes.draw do

  use_doorkeeper

  get "/404" => "errors#not_found"
  get "/500" => "errors#exception"

  api_version(module: "V0", path: {value: "v0"}, default: true) do
    resources :me, only: [:index] do
      patch '/' => 'me#update', on: :collection
    end
    resources :readings, only: :create
    resources :users, only: [:index, :show, :create]
    resources :sensors
    resources :components
    resources :kits
    resources :devices do
      resources :readings, only: :index
      get 'world_map', on: :collection
    end
    root to: 'static#home'
  end
  root to: 'v0/static#home'

end
