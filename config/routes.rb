Rails.application.routes.draw do
  resources :assignments do
    resources :tests
  end
end
