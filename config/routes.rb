Rails.application.routes.draw do

  api_version(module: "V0", path: {value: "v0"}, header: {name: "Accept", value: "application/vnd.smartcitizen; version=0"}, default: true, defaults: { format: :json }) do
    # devices
    resources :devices do
      resources :readings, only: :index
      resources :pg_readings, only: :index, on: :member
      get 'world_map', on: :collection
    end
    # readings
    resources :readings, only: [:create]
    match "add" => "readings#add", via: [:get, :post, :patch, :put]
    # sensors
    resources :sensors, except: [:destroy]
    # components
    resources :components, only: :index
    resources :sessions
    # kits
    resources :kits, except: [:create, :destroy]
    # users
      resources :users, only: [:index, :show, :create, :update]
      # password_resets
      resources :password_resets, only: [:show, :create, :update]
      # me
      resources :me, only: [:index] do
        patch '/' => 'me#update', on: :collection
        put '/' => 'me#update', on: :collection
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
