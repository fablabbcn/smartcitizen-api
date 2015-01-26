Rails.application.routes.draw do

  use_doorkeeper

  get "/404" => "errors#not_found"
  get "/500" => "errors#exception"

  api_version(module: "V0", path: {value: "v0"}) do
    resources :users
  end

end
