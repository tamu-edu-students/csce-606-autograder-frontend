Rails.application.routes.draw do
  resources :assignments do
    resources :tests, only: [:index, :new, :create, :edit, :update, :destroy]
  end
end
