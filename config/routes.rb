Rails.application.routes.draw do
  namespace :v1 do
    resources :blobs, only: [:create, :show]
  end
  get "up" => "rails/health#show", as: :rails_health_check

end
