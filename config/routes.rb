Rails.application.routes.draw do
  root 'components#index'
  resources :ask, only: [:create]
end
