Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  root "home#index"

  resources :users
  resources :patients do
    resources :patient_consents, only: :create
  end
  resources :appointments
  resources :treatment_records
  resources :invoices
  resources :payments
  resources :notifications
  resources :audit_logs, only: :index
  resource :compliance, only: :show, controller: "compliance"
  resources :clinic_services
  resources :document_templates do
    member { get :preview }
  end

  namespace :portal do
    resource :dashboard, only: :show, controller: "dashboard"
    resources :intake_forms, only: %i[index new create], controller: "intake_forms"
  end

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
