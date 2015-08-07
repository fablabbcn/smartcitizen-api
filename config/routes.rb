Rails.application.routes.draw do

  api_version(module: "V001", path: {value: "v0.0.1"}, header: {name: "Accept", value: "application/vnd.smartcitizen; version=0.0.1"}, defaults: { format: :json }) do
    get ':api_key/devices', to: 'devices#index'
    get ':api_key/lastpost', to: 'devices#current_user_index'
    get ':api_key/post', to: 'readings#show'
    get ':api_key/me', to: 'users#show'
  end

  # api_version(module: "V2", path: {value: "v2"}, header: {name: "Accept", value: "application/vnd.smartcitizen; version=2"}, default: false, defaults: { format: :json }) do
  #   # devices
  #   resources :devices do
  #     resources :pg_readings, only: :index, on: :member
  #     resources :readings, only: :index, on: :member
  #     get 'world_map', on: :collection
  #   end
  #   # readings
  #   match "add" => "readings#create", via: [:get, :post, :patch, :put]
  #   # sensors
  #   resources :sensors, except: [:destroy]
  #   # components
  #   resources :components, only: :index
  #   resources :sessions

  #   resources :uploads, path: 'avatars' do
  #     post 'uploaded' => 'uploads#uploaded', on: :collection
  #   end

  #   resources :measurements
  #   # kits
  #   resources :kits, except: [:create, :destroy]
  #   # users
  #     resources :users, only: [:index, :show, :create, :update]
  #     # password_resets
  #     resources :password_resets, only: [:show, :create, :update]
  #     # me
  #     resources :me, only: [:index] do
  #       patch 'avatar' => 'uploads#create', on: :collection
  #       post 'avatar' => 'uploads#create', on: :collection
  #       patch '/' => 'me#update', on: :collection
  #       put '/' => 'me#update', on: :collection
  #     end
  #   # home
  #   get 'search' => 'static#search'

  #   # use_doorkeeper
  #   # root to: 'static#home'
  #   get '/' => 'static#home'
  # end


  api_version(module: "V0", path: {value: "v0"}, header: {name: "Accept", value: "application/vnd.smartcitizen; version=0"}, default: true, defaults: { format: :json }) do
    # devices
    resources :devices do
      resources :pg_readings, only: :index, on: :member
      resources :readings, only: :index, on: :member
      get 'world_map', on: :collection
    end
    # readings
    match "add" => "readings#create", via: [:get, :post, :patch, :put]
    # sensors
    resources :sensors, except: [:destroy]
    # components
    resources :components, only: :index
    resources :sessions

    resources :uploads, path: 'avatars' do
      post 'uploaded' => 'uploads#uploaded', on: :collection
    end

    resources :measurements
    # kits
    resources :kits, except: [:create, :destroy]
    # users
      resources :users, only: [:index, :show, :create, :update]
      # password_resets
      resources :password_resets, only: [:show, :create, :update]
      # me
      resources :me, only: [:index, :destroy] do
        patch 'avatar' => 'uploads#create', on: :collection
        post 'avatar' => 'uploads#create', on: :collection
        patch '/' => 'me#update', on: :collection
        put '/' => 'me#update', on: :collection
        delete '/' => 'me#destroy', on: :collection
      end

    # home
    get 'search' => 'static#search'

    # use_doorkeeper
    root to: 'static#home'
  end

  # get '*path', :to => redirect("/v0/%{path}")
  # root to: redirect('/v0')

  get "/404" => "errors#not_found"
  get "/500" => "errors#exception"
  match "*path", to: "errors#not_found", via: :all

end
