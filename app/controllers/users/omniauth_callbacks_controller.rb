module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token, only: [:github, :google_oauth2, :facebook, :twitter2]

    # Handle GitHub OAuth callback
    def github
      handle_auth("GitHub")
    end

    # Handle Google OAuth callback
    def google_oauth2
      handle_auth("Google")
    end

    # Handle Facebook OAuth callback
    def facebook
      handle_auth("Facebook")
    end

    # Handle Twitter OAuth callback
    def twitter2
      handle_auth("Twitter")
    end

    # Handle OAuth failures
    def failure
      redirect_to new_user_session_path, alert: "Authentication failed: #{params[:message]}"
    end

    private

    def handle_auth(kind)
      auth = request.env["omniauth.auth"]

      # Get the record to associate with (signed global ID or current_user)
      owner = get_owner_from_params || current_user

      # Handle different scenarios based on whether owner exists and is logged in
      if owner
        # User is logged in or we have a specific owner - connect account
        handle_connected_account(owner, auth, kind)
      else
        # User is not logged in - try to find existing user or create new one
        handle_user_authentication(auth, kind)
      end
    end

    def handle_connected_account(owner, auth, kind)
      # Find or create connected account
      connected_account = owner.connected_accounts.where(provider: auth.provider, uid: auth.uid).first_or_initialize

      # Update the connected account with new data
      connected_account.update(
        access_token: auth.credentials.token,
        access_token_secret: auth.credentials.secret,
        refresh_token: auth.credentials.refresh_token,
        expires_at: auth.credentials.expires_at ? Time.at(auth.credentials.expires_at) : nil,
        auth: auth.as_json
      )

      # Handle redirect_to param if provided
      redirect_path = get_redirect_path || (owner.is_a?(User) ? edit_user_registration_path : root_path)

      # If it's a new account, show success message
      if connected_account.previously_new_record?
        redirect_to redirect_path, notice: "#{kind} account connected successfully."
      else
        redirect_to redirect_path, notice: "#{kind} account updated successfully."
      end
    end

    def handle_user_authentication(auth, kind)
      # First, try to find a user with this connected account
      connected_account = ConnectedAccount.where(provider: auth.provider, uid: auth.uid).first

      if connected_account
        # Found existing connected account - sign in the user
        user = connected_account.owner
        if user.is_a?(User)
          # Update the connected account with new data
          connected_account.update(
            access_token: auth.credentials.token,
            access_token_secret: auth.credentials.secret,
            refresh_token: auth.credentials.refresh_token,
            expires_at: auth.credentials.expires_at ? Time.at(auth.credentials.expires_at) : nil,
            auth: auth.as_json
          )

          sign_in_and_redirect user, event: :authentication
          set_flash_message(:notice, :success, kind: kind) if is_navigational_format?
        else
          # Connected account owner is not a User (maybe an Account)
          redirect_to new_user_session_path, alert: "This #{kind} account is not associated with a user account."
        end
      else
        # No connected account found - try to find user by email
        email = auth.info.email

        if email.present?
          user = User.where(email: email).first

          if user
            # User exists with this email - DO NOT automatically connect
            # Require the user to be logged in to connect their account
            redirect_to new_user_session_path, alert: "An account with this email already exists. Please sign in first to connect your #{kind} account."
          else
            # Create new user with connected account
            create_user_from_auth(auth, kind)
          end
        else
          # No email provided by OAuth provider
          redirect_to new_user_registration_path, alert: "Could not get your email from #{kind}. Please sign up manually."
        end
      end
    end

    def create_user_from_auth(auth, kind)
      # Extract name parts
      name_parts = extract_name_parts(auth)

      # Create user
      user = User.new(
        email: auth.info.email,
        first_name: name_parts[:first_name],
        last_name: name_parts[:last_name],
        password: Devise.friendly_token[0, 20],
        confirmed_at: Time.current # Auto-confirm users who sign up via OAuth
      )

      if user.save
        # Create connected account
        user.connected_accounts.create!(
          provider: auth.provider,
          uid: auth.uid,
          access_token: auth.credentials.token,
          access_token_secret: auth.credentials.secret,
          refresh_token: auth.credentials.refresh_token,
          expires_at: auth.credentials.expires_at ? Time.at(auth.credentials.expires_at) : nil,
          auth: auth.as_json
        )

        sign_in_and_redirect user, event: :authentication
        set_flash_message(:notice, :success, kind: kind) if is_navigational_format?
      else
        redirect_to new_user_registration_path, alert: "Could not create account: #{user.errors.full_messages.join(', ')}"
      end
    end

    def extract_name_parts(auth)
      name = auth.info.name || ""
      first_name = auth.info.first_name
      last_name = auth.info.last_name

      # If first_name and last_name are not provided, try to split the name
      if first_name.blank? && last_name.blank?
        parts = name.split(" ", 2)
        first_name = parts[0] || ""
        last_name = parts[1] || ""
      end

      {
        first_name: first_name.presence || "User",
        last_name: last_name.presence || ""
      }
    end

    def get_owner_from_params
      return nil unless params[:record].present?

      begin
        GlobalID::Locator.locate_signed(params[:record], for: :oauth)
      rescue ActiveRecord::RecordNotFound, SignedGlobalID::ExpiredMessage
        nil
      end
    end

    def get_redirect_path
      params[:redirect_to].presence
    end
  end
end
