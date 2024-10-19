require "sidekiq/web"
Rails.application.routes.draw do
  if Rails.env.production?
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      username == ENV["sidekiq_username"] && password == ENV["sidekiq_password"]
    end
  end
  mount Sidekiq::Web, at: "/sidekiq"

  get "discourse/sso" => 'discourse#sso'

  get 'login', to: 'ui/sessions#new', as: 'login'
  get 'logout', to: 'ui/sessions#destroy', as: 'logout'
  get 'password_reset/:token', to: 'ui/sessions#password_reset_landing', as: 'password_reset'

  post 'change_password', to: 'ui/sessions#change_password', as: 'change_password'

  namespace "ui" do
    resources :users, as: "users"
    resources :sessions, as: "sessions"
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
    resources :experiments

    resources :tag_sensors
    resources :tags
    resources :measurements

    constraints id: /[^\/]+/ do
      # Explicitly override to allow usernames with dots.
      # See:https://stackoverflow.com/questions/5369654/why-do-routes-with-a-dot-in-a-parameter-fail-to-match
      resources :users
    end
    resources :password_resets, only: [:show, :create, :update]
    resources :oauth_applications, path: 'applications'
    get :forward, to: "forwarding#authorize"

    resources :me, only: [:index] do
      patch '/' => 'me#update', on: :collection
      put '/' => 'me#update', on: :collection
      delete '/' => 'me#destroy', on: :collection
    end

    # onboarding process
    namespace :onboarding do
      get 'device', to: 'orphan_devices#show'
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
    get '/version', to: "static#version"
    get "/404" => "errors#not_found"
    get "/500" => "errors#exception"
    get "/test_error" => "errors#test_error"

    # Active Storage cannot show the correct url if using catchall matchers
    # https://github.com/rails/rails/issues/31228
    # Disable until a solution is found
    #match "*path", to: "errors#not_found", via: :all
  end

  # get '*path', :to => redirect("/v0/%{path}")
  # root to: redirect('/v0')

end
