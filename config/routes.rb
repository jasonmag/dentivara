Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"

  resources :users
  resources :patients
  resources :appointments
  resources :treatment_records
  resources :invoices
  resources :payments
  resources :notifications

  namespace :api do
    namespace :v1 do
      resources :patients
      resources :appointments
      resources :treatment_records
      resources :invoices
      resources :payments
      resources :notifications
    end
  end
end
