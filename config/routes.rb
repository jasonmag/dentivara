Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  root "home#index"
  get "dashboard", to: "home#dashboard"

  resources :users
  resource :clinic_settings, only: %i[show update], controller: "clinic_settings"
  resource :role_permission, only: %i[new create]
  get "reports/dental_chart_surfaces", to: "reports#dental_chart_surfaces", as: :dental_chart_surfaces_report
  resources :patients do
    resources :patient_consents, only: :create
    resources :dental_chart_entries, only: :create
    resources :intraoral_scans, only: %i[show create destroy]
    resources :prescriptions, only: %i[index show new create] do
      collection do
        get :render_template
      end
      member do
        patch :finalize
        patch :sign
      end
    end
  end
  resources :appointments do
    get :details, on: :member
    collection do
      get :available_slots
    end
  end
  resources :queue_entries, only: %i[index create] do
    collection do
      post :call_next
    end
    member do
      patch :call
      patch :serve
      patch :cancel
    end
  end
  resource :schedule_settings, only: :show, controller: "schedule_settings" do
    post :clinic_schedules, action: :create_clinic_schedule
    delete "clinic_schedules/:id", action: :destroy_clinic_schedule, as: :clinic_schedule
    post :clinic_closures, action: :create_clinic_closure
    delete "clinic_closures/:id", action: :destroy_clinic_closure, as: :clinic_closure
    post :dentist_schedules, action: :create_dentist_schedule
    delete "dentist_schedules/:id", action: :destroy_dentist_schedule, as: :dentist_schedule
    post :dentist_overrides, action: :create_dentist_override
    delete "dentist_overrides/:id", action: :destroy_dentist_override, as: :dentist_override
  end
  resources :treatment_records
  resources :invoices do
    member do
      get :download
    end
  end
  resources :payments do
    member do
      get :receipt
    end
  end
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
      resource :session, only: %i[create destroy]
      resource :clinic_onboarding, only: :create, controller: "clinic_onboarding"
      resource :clinic_context, only: :update, controller: "clinic_context"
      resource :patient_registration, only: :create, controller: "patient_registrations"
      resource :patient_claim, only: :create, controller: "patient_claims"
      resource :patient_portal, only: :show, controller: "patient_portal"
      resource :platform_overview, only: :show, controller: "platform_overview"
      resource :platform_settings, only: %i[show update], controller: "platform_settings"
      resources :platform_accounts, only: %i[create update], controller: "platform_accounts"
      resource :account_subscription, only: %i[show create], controller: "account_subscriptions"
      resources :account_subscriptions, only: :update, controller: "account_subscriptions"
      resources :subscription_plans
      resource :impersonation, only: :create, controller: "impersonations"
      resource :dashboard, only: :show, controller: "dashboard"
      resources :clinics, only: %i[index show create update destroy]
      resources :patients
      resources :appointments
      resources :treatment_records
      resources :invoices
      resources :payments
      resources :notifications
      resources :clinic_services
      resources :users, only: :index
    end
  end
end
