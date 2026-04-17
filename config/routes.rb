Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "employees#index"

  devise_for :users

  get "organisation_settings", to: "pages#organisation_settings", as: :organisation_settings

  resources :job_titles
  resources :departments

  resources :employees do
    member { patch :salary }
  end

  get "insights", to: "insights#index", as: :insights

  namespace :api do
    namespace :v1 do
      devise_scope :user do
        post   "users/sign_in",  to: "auth/sessions#create",       as: :api_v1_user_session
        delete "users/sign_out", to: "auth/sessions#destroy",      as: :destroy_api_v1_user_session
        post   "users",          to: "auth/registrations#create",  as: :api_v1_user_registration
        post   "users/refresh",  to: "auth/tokens#create",         as: :refresh_api_v1_user_token
      end

      resources :employees do
        member do
          patch :salary
          get   :salary_history
        end
      end

      resources :job_titles, only: [ :index ]
      resources :departments, only: [ :index ]
      resources :countries, only: [ :index ]

      namespace :insights do
        resources :salary, only: [ :index ]
      end
    end
  end
end
