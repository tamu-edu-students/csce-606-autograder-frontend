Rails.application.routes.draw do
  root "pages#home"
  get "pages/home"

  resources :users, only: [ :index, :show ]
  resources :assignments, only: [ :index ]
  post "users/:id/update_assignments", to: "users#update_assignments", as: "update_user_assignments"

  resources :assignments do
    resources :tests
    collection do
      get "search"
    end
    member do
      get "create_and_download_zip"
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get "/auth/github/callback", to: "sessions#create"
  get "/auth/failure", to: "sessions#failure"
  delete "/logout", to: "sessions#destroy"
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
