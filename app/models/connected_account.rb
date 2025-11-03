class ConnectedAccount < ApplicationRecord
  belongs_to :owner, polymorphic: true

  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }

  # Store the auth hash as JSON
  serialize :auth, coder: JSON

  # Automatically create scopes for each provider
  # Usage: ConnectedAccount.twitter, ConnectedAccount.github, etc.
  scope :github, -> { where(provider: "github") }
  scope :google_oauth2, -> { where(provider: "google_oauth2") }
  scope :facebook, -> { where(provider: "facebook") }
  scope :twitter, -> { where(provider: "twitter2") }

  # Returns an active token, automatically renewing if expired
  def token
    if expired?
      refresh_token!
    end
    access_token
  end

  # Check if the token is expired
  def expired?
    expires_at? && Time.current >= expires_at
  end

  # Refresh the token if it's expired (OAuth 2.0 only)
  def refresh_token!
    return unless refresh_token.present?

    # This is a placeholder - you'll need to implement provider-specific refresh logic
    # For example, for Google OAuth2:
    # response = HTTParty.post(
    #   'https://oauth2.googleapis.com/token',
    #   body: {
    #     client_id: Rails.application.credentials.dig(:omniauth, :google_oauth2, :client_id),
    #     client_secret: Rails.application.credentials.dig(:omniauth, :google_oauth2, :client_secret),
    #     refresh_token: refresh_token,
    #     grant_type: 'refresh_token'
    #   }
    # )
    #
    # if response.success?
    #   update(
    #     access_token: response['access_token'],
    #     expires_at: Time.current + response['expires_in'].seconds
    #   )
    # end
  end

  # Get data from the auth hash
  def name
    auth&.dig("info", "name")
  end

  def email
    auth&.dig("info", "email")
  end

  def nickname
    auth&.dig("info", "nickname")
  end

  def image
    auth&.dig("info", "image")
  end

  # Get the full auth info
  def info
    auth&.dig("info") || {}
  end

  # Get extra data from the auth hash
  def extra
    auth&.dig("extra") || {}
  end
end
