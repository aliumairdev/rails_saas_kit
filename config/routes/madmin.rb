# Below are the routes for madmin
namespace :madmin do
  namespace :active_storage do
    resources :attachments
  end
  namespace :active_storage do
    resources :blobs
  end
  resources :account_invitations
  resources :account_users
  resources :announcements
  namespace :paper_trail do
    resources :versions
  end
  resources :accounts
  resources :announcement_dismissals
  resources :api_tokens
  resources :plans
  resources :users
  namespace :noticed do
    resources :events
  end
  namespace :noticed do
    resources :notifications
  end
  namespace :pay do
    resources :charges
  end
  namespace :pay do
    resources :customers
  end
  namespace :pay do
    resources :merchants
  end
  namespace :pay do
    resources :payment_methods
  end
  namespace :pay do
    resources :subscriptions
  end
  root to: "dashboard#show"
end
