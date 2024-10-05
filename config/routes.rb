Rails.application.routes.draw do
  resources :assignments do
    resources :tests
    member do
      get 'create_and_download_zip'
    end
  end
end
