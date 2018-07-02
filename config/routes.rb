require "sidekiq/web"
Rails.application.routes.draw do


  get 'version', to: "version#index"

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["sidekiq_username"] && password == ENV["sidekiq_password"]
  end if Rails.env.production?
  mount Sidekiq::Web, at: "/sidekiq"

  # resources :tags, except: [:new, :edit]
  api_version(module: "V001", path: {value: "v0.0.1"}, header: {name: "Accept", value: "application/vnd.smartcitizen; version=0.0.1"}, defaults: { format: :json }) do
    get ':api_key/devices', to: 'devices#index'
    get ':api_key/lastpost', to: 'devices#current_user_index'
    get ':api_key/:device_id/posts', to: 'devices#show'
    get ':api_key/me', to: 'users#show'
    get '/', to: 'static#home'

    get "/404" => "errors#not_found"
    get "/500" => "errors#exception"
    match "*path", to: "errors#not_found", via: :all
  end

  api_version(module: "V0", path: {value: "v0"}, header: {name: "Accept", value: "application/vnd.smartcitizen; version=0"}, default: true, defaults: { format: :json }) do
    # devices
    resources :devices do
      member do
        resources :readings, only: [:index, :create] do
          get 'csv_archive', on: :collection
        end
      end
      get 'world_map', on: :collection
      get 'fresh_world_map', on: :collection
    end
    # readings
    match "add" => "readings#legacy_create", via: [:get, :post, :patch, :put]
    match "datetime" => "readings#datetime", via: [:get, :post, :patch, :put]

    resources :sensors, except: [:destroy]
    resources :components, only: [:show, :index]
    resources :sessions, only: :create

    resources :uploads, path: 'avatars' do
      post 'uploaded' => 'uploads#uploaded', on: :collection
    end

    resources :tags
    resources :measurements
    resources :kits, except: [:destroy]
    resources :users
    resources :password_resets, only: [:show, :create, :update]
    resources :oauth_applications, path: 'applications'

    resources :me, only: [:index] do
      patch 'avatar' => 'uploads#create', on: :collection
      post 'avatar' => 'uploads#create', on: :collection
      patch '/' => 'me#update', on: :collection
      put '/' => 'me#update', on: :collection
      delete '/' => 'me#destroy', on: :collection
    end

    # onboarding process
    namespace :onboarding do
      post 'device', to: 'orphan_devices#create'
      patch 'device', to: 'orphan_devices#update'
      post 'user', to: 'device_registrations#find_user'
      post 'register', to: 'device_registrations#register_device'
    end

    get "discourse/sso" => 'discourse#sso'
    get 'search' => 'static#search'
    get 'metrics' => 'static#metrics'
    # use_doorkeeper
    # root to: 'static#home'
    get '/', to: 'static#home'

    get "/404" => "errors#not_found"
    get "/500" => "errors#exception"
    get "/test_error" => "errors#test_error"
    match "*path", to: "errors#not_found", via: :all

  end

  # get '*path', :to => redirect("/v0/%{path}")
  # root to: redirect('/v0')

end
