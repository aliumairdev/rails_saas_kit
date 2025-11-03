Rails.application.routes.draw do
  draw :madmin
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  # Two-Factor Authentication
  namespace :users do
    resource :two_factor_authentication, only: [:show, :new, :create, :destroy] do
      get :backup_codes
      post :regenerate_backup_codes
    end
    resource :otp, only: [:show, :create]
  end

  # Authenticated routes
  authenticated :user do
    root to: "dashboard#index", as: :authenticated_root
  end

  # Dashboard
  get "dashboard", to: "dashboard#index"

  # Pricing
  get "pricing", to: "pricing#index"

  # Review tracking (public, no auth required)
  get "r/:token", to: "review_clicks#show", as: :review_click

  # Notifications
  resources :notifications, only: [:index] do
    member do
      post :mark_as_read
    end
    collection do
      post :mark_all_as_read
    end
  end

  # Notification Preferences
  resource :notification_preferences, only: [:edit, :update]

  # Accounts
  resources :accounts do
    member do
      post :switch
    end

    # Account Settings (nested under account)
    scope module: :account do
      get "settings", to: "settings#index", as: :settings
      get "settings/general", to: "settings#general", as: :settings_general
      get "settings/members", to: "settings#members", as: :settings_members
      get "settings/billing", to: "settings#billing", as: :settings_billing
    end

    # Billing routes
    get "billing", to: "accounts/billing#show", as: :billing
    scope module: :accounts do
      resource :billing, only: [:show] do
        get :new, to: "billing#new"
        post :create, to: "billing#create"
      end

      # Invitations
      resources :invitations, only: [:index, :new, :create, :destroy] do
        member do
          post :resend
        end
      end
    end
  end

  # Public invitation acceptance routes (no authentication required)
  get "invitations/:token", to: "invitation_acceptances#show", as: :invitation
  post "invitations/:token/accept", to: "invitation_acceptances#accept", as: :accept_invitation

  # API Tokens
  resources :api_tokens, only: [:index, :new, :create, :destroy]

  # Announcements
  resources :announcement_dismissals, only: [:create]

  # Admin impersonation
  namespace :admin do
    post "users/:user_id/impersonate", to: "impersonations#create", as: :impersonate_user
    delete "impersonate", to: "impersonations#destroy", as: :stop_impersonating
  end

  # API v1 routes
  namespace :api do
    namespace :v1 do
      resources :campaigns, only: [:index, :show, :create]
      resources :customers, only: [:index, :show, :create]
      resources :review_requests, only: [:index, :show, :create]
    end
  end

  # Error pages
  match "/404", to: "errors#not_found", via: :all
  match "/422", to: "errors#unprocessable_entity", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/") - landing page for non-authenticated users
  root "pages#home"
end
