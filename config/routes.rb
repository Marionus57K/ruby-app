Rails.application.routes.draw do
  get 'new_case/index'
  get "/dataset", to: "dataset#index"
  get "/male-chart", to: "malechart#index"
  get "/new-case", to: "newcase#index"

  post '/createcase' => 'application#createcase'
  post '/submitcase' => 'application#submitcase'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
