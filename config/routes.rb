Rails.application.routes.draw do

  api_version(module: "V0", path: {value: "v0"}, default: true) do
    # devices
    resources :devices do
      resources :readings, only: :index
      get 'world_map', on: :collection
    end
    # readings
    resources :readings, only: [:create]
    match "add" => "readings#add", via: [:get, :post, :patch, :put]
    # sensors
    resources :sensors, only: [:index, :show, :create]
    # components
    resources :components, only: :index
    # kits
    resources :kits, only: [:index, :show]
    # users
      resources :users, only: [:index, :show, :create, :update]
      # password_resets
      resources :password_resets, only: [:create, :update]
      # me
      resources :me, only: [:index] do
        patch '/' => 'me#update', on: :collection
      end
    # home
    get 'search' => 'static#search'
    root to: 'static#home'
  end

  # use_doorkeeper
  get "/404" => "errors#catch_404"
  get "/500" => "errors#exception"
  match "*path", to: "errors#catch_404", via: :all

  # get '*path', :to => redirect("/v0/%{path}")
  # root to: redirect('/v0')

end
