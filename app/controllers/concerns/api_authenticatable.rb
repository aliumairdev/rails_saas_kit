module ApiAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_with_api_token!
  end

  private

  def authenticate_with_api_token!
    token = extract_token_from_header

    if token.blank?
      render_unauthorized("Missing API token")
      return
    end

    api_token = ApiToken.find_by_token(token)

    if api_token.nil?
      render_unauthorized("Invalid API token")
      return
    end

    if api_token.expired?
      render_unauthorized("API token has expired")
      return
    end

    # Set current user and account
    @current_user = api_token.user
    @current_api_token = api_token

    # Set Current.account to user's default account (first account)
    Current.account = @current_user.accounts.first

    # Update last used timestamp
    api_token.mark_as_used!
  end

  def current_user
    @current_user
  end

  def current_api_token
    @current_api_token
  end

  def extract_token_from_header
    auth_header = request.headers["Authorization"]
    return nil if auth_header.blank?

    # Expected format: "Bearer token_here"
    match = auth_header.match(/^Bearer\s+(.+)$/i)
    match ? match[1] : nil
  end

  def render_unauthorized(message = "Unauthorized")
    render json: { error: message }, status: :unauthorized
  end

  def render_forbidden(message = "Forbidden")
    render json: { error: message }, status: :forbidden
  end

  def render_unprocessable_entity(errors)
    render json: { errors: errors }, status: :unprocessable_entity
  end

  def api_request?
    true
  end
end
