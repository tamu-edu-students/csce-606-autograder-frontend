Rails.application.routes.draw do
  root 'pages#home' 
  get "pages/home"

  resources :assignments
 
  get '/auth/github/callback', to: 'sessions#create'
  get '/auth/failure', to: redirect('/')
  delete 'logout', to: 'sessions#destroy'

  # resources :users do
  #   member do
  #     patch :update_multiple_repo_permissions
  #   end
  # end

  # resources :users do
  #   resources :assignments, only: [:index] 
  # end
  # get 'users/:user_id/assignments/view', to: 'assignments#user_assignments', as: :user_assignment_view

  resources :users, only: [:index, :show]
  resources :assignments, only: [:index]
  post 'users/:id/update_assignments', to: 'users#update_assignments', as: 'update_user_assignments'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end