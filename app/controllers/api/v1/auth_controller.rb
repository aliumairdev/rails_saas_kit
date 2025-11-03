module Api
  module V1
    class AuthController < ActionController::API
      # POST /api/v1/auth.json
      # Authenticate with email and password to receive an API token
      # Params: { email: "user@example.com", password: "password" }
      # Returns: { token: "token_abc123..." }
      def create
        user = User.find_by(email: auth_params[:email])

        if user&.valid_password?(auth_params[:password])
          # Check if user has confirmed their email
          unless user.confirmed?
            render json: { error: "Please confirm your email address before accessing the API" }, status: :unauthorized
            return
          end

          # Create a new API token for this user
          api_token = user.api_tokens.create!(
            name: "API Authentication Token",
            transient: false
          )

          render json: {
            token: api_token.token,
            user: {
              id: user.id,
              email: user.email,
              name: user.name
            }
          }, status: :created
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      private

      def auth_params
        params.permit(:email, :password)
      end
    end
  end
end
