Rails.application.routes.draw do
  root "pages#home"
  get "pages/home"

  resources :assignments do
    resources :tests
  end
  
  # Authentication routes
  get "/auth/github/callback", to: "sessions#create"
  get "/auth/failure", to: "sessions#failure"
  delete "/logout", to: "sessions#destroy"

  # Health check and PWA routes
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
