# OAuth / Social Login Setup Guide

This Rails SaaS Kit includes comprehensive OAuth authentication support, allowing users to sign up and log in using their social media accounts.

## Features

✅ **User registration with OAuth** - New users can sign up using their social accounts
✅ **Sign in with OAuth** - Existing users can log in using previously connected accounts
✅ **Account linking** - Logged-in users can connect multiple social accounts
✅ **Account management** - Users can view and disconnect their social accounts
✅ **Multiple providers** - GitHub, Google, Facebook, and Twitter support included
✅ **Secure token storage** - OAuth tokens are securely stored and automatically refreshed
✅ **Email verification** - Users who sign up via OAuth are automatically confirmed

## Supported Providers

- **GitHub** (`omniauth-github`)
- **Google** (`omniauth-google-oauth2`)
- **Facebook** (`omniauth-facebook`)
- **Twitter** (`omniauth-twitter2`)

## Installation

The OAuth functionality has been pre-configured. You just need to:

1. **Run the migration** to create the `connected_accounts` table:
   ```bash
   rails db:migrate
   ```

2. **Configure OAuth provider credentials** (see below)

## Configuration

### Setting Up OAuth Providers

To enable OAuth providers, you need to obtain OAuth credentials from each provider and add them to your Rails credentials.

#### 1. Edit Rails Credentials

```bash
EDITOR="nano" rails credentials:edit
```

Or use your preferred editor:
```bash
EDITOR="code --wait" rails credentials:edit
```

#### 2. Add Provider Credentials

Add the following structure to your `config/credentials.yml.enc`:

```yaml
omniauth:
  github:
    client_id: your_github_client_id
    client_secret: your_github_client_secret
  google_oauth2:
    client_id: your_google_client_id
    client_secret: your_google_client_secret
  facebook:
    app_id: your_facebook_app_id
    app_secret: your_facebook_app_secret
  twitter2:
    api_key: your_twitter_api_key
    api_secret: your_twitter_api_secret
```

### Obtaining OAuth Credentials

#### GitHub

1. Go to [GitHub Developer Settings](https://github.com/settings/developers)
2. Click "New OAuth App"
3. Fill in the application details:
   - **Application name**: Your App Name
   - **Homepage URL**: `http://localhost:3000` (for development)
   - **Authorization callback URL**: `http://localhost:3000/users/auth/github/callback`
4. Copy the `Client ID` and generate a `Client Secret`

#### Google

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable the Google+ API
4. Go to "Credentials" → "Create Credentials" → "OAuth client ID"
5. Configure the OAuth consent screen
6. Add authorized redirect URIs:
   - `http://localhost:3000/users/auth/google_oauth2/callback`
7. Copy the `Client ID` and `Client secret`

#### Facebook

1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Create a new app or select existing one
3. Add "Facebook Login" product
4. Configure OAuth redirect URIs:
   - `http://localhost:3000/users/auth/facebook/callback`
5. Copy the `App ID` and `App Secret` from Settings → Basic

#### Twitter

1. Go to [Twitter Developer Portal](https://developer.twitter.com/en/portal/dashboard)
2. Create a new app
3. Enable OAuth 2.0
4. Add callback URL:
   - `http://localhost:3000/users/auth/twitter2/callback`
5. Copy the `API Key` and `API Secret Key`

### Production Configuration

For production, update the callback URLs to use your production domain:

```
https://yourdomain.com/users/auth/[provider]/callback
```

Replace `[provider]` with: `github`, `google_oauth2`, `facebook`, or `twitter2`

## Usage

### User Sign Up / Sign In

OAuth buttons are automatically displayed on the sign-in and sign-up pages. Users can:

1. Click "Sign in with [Provider]"
2. Authorize the application on the provider's site
3. Get redirected back and automatically signed in

### Managing Connected Accounts

Users can manage their connected social accounts at:

```
/connected_accounts
```

From this page, users can:
- View all connected accounts
- Connect new social accounts
- Disconnect existing accounts

### Programmatic Usage

#### Check if user has a connected account

```ruby
if current_user.connected_accounts.github.any?
  github_account = current_user.connected_accounts.github.first
  puts "Connected to GitHub as #{github_account.nickname}"
end
```

#### Access OAuth tokens

```ruby
# Get the access token (automatically refreshed if expired)
github_account = current_user.connected_accounts.github.first
token = github_account.token

# Use with API clients
client = Octokit::Client.new(access_token: token)
user = client.user
```

#### Access user data from the provider

```ruby
connected_account = current_user.connected_accounts.github.first

# Get basic info
connected_account.name        # User's name
connected_account.email       # User's email
connected_account.nickname    # Username/handle
connected_account.image       # Avatar URL

# Get full auth hash
connected_account.auth        # Complete OAuth data
connected_account.info        # User info hash
connected_account.extra       # Extra data hash
```

### Connect Account to Current User

You can create buttons that connect accounts to the currently logged-in user:

```erb
<%= button_to "Connect GitHub",
    omniauth_authorize_path(:user, :github),
    data: { turbo: false },
    class: "btn btn-primary" %>
```

### Associate Account with Other Models

You can associate connected accounts with other models (e.g., Team, Organization):

```erb
<%= button_to "Connect GitHub to Team",
    omniauth_authorize_path(
      :user,
      :github,
      record: @team.to_sgid(for: :oauth),
      redirect_to: team_path(@team)
    ),
    data: { turbo: false },
    class: "btn btn-primary" %>
```

The `record` parameter accepts a Signed Global ID, and the connected account will be associated with that record instead of the current user.

## Security Features

### CSRF Protection

The app includes `omniauth-rails_csrf_protection` to prevent CSRF attacks on OAuth callbacks.

### Token Refresh

The `ConnectedAccount#token` method automatically refreshes expired tokens when available:

```ruby
# This will automatically refresh the token if expired
access_token = connected_account.token
```

### Secure Credential Storage

OAuth credentials are stored in Rails encrypted credentials, not in environment variables or version control.

## Architecture

### Models

- **User**: Extended with `:omniauthable` Devise module and `has_many :connected_accounts`
- **ConnectedAccount**: Polymorphic model storing OAuth provider data and tokens

### Controllers

- **Users::OmniauthCallbacksController**: Handles OAuth callbacks for all providers
- **ConnectedAccountsController**: Manages viewing and deleting connected accounts

### Routes

```ruby
# OAuth callbacks (handled by Devise)
/users/auth/:provider          # Initiates OAuth flow
/users/auth/:provider/callback # OAuth callback endpoint

# Connected accounts management
/connected_accounts            # List connected accounts
/connected_accounts/:id        # Delete connected account
```

## Customization

### Adding New Providers

1. Add the omniauth gem to your `Gemfile`:
   ```ruby
   gem "omniauth-linkedin-oauth2"
   ```

2. Add provider to User model:
   ```ruby
   devise :omniauthable, omniauth_providers: [..., :linkedin]
   ```

3. Configure in `config/initializers/devise.rb`:
   ```ruby
   config.omniauth :linkedin,
     Rails.application.credentials.dig(:omniauth, :linkedin, :client_id),
     Rails.application.credentials.dig(:omniauth, :linkedin, :client_secret)
   ```

4. Add callback method in `Users::OmniauthCallbacksController`:
   ```ruby
   def linkedin
     handle_auth("LinkedIn")
   end
   ```

5. Add translations to `config/locales/en.yml`:
   ```yaml
   oauth:
     linkedin: "LinkedIn"
   ```

### Customizing OAuth Behavior

Override methods in `Users::OmniauthCallbacksController` to customize behavior:

- `handle_auth` - Main OAuth handling logic
- `create_user_from_auth` - Customize user creation
- `handle_connected_account` - Customize account linking

### Customizing Views

OAuth buttons are rendered in `app/views/devise/shared/_links.html.erb`. Customize the styling or layout as needed.

Connected accounts page is at `app/views/connected_accounts/index.html.erb`.

## Troubleshooting

### OAuth buttons not showing

Make sure:
1. Provider credentials are configured in Rails credentials
2. The provider is listed in the User model's `omniauth_providers`
3. The `:omniauthable` module is enabled in the User model

### "Redirect URI mismatch" error

Ensure the callback URL in your OAuth app settings matches exactly:
```
http://localhost:3000/users/auth/[provider]/callback
```

### Expired token errors

The `ConnectedAccount#token` method should automatically refresh tokens. If you're still having issues:
1. Check that `refresh_token` is being stored
2. Implement provider-specific refresh logic in `ConnectedAccount#refresh_token!`

### Email already exists error

By design, users must be logged in to connect an OAuth account if an account with that email already exists. This prevents account takeover attacks.

## Testing

Run the test suite:

```bash
rails test
```

For OAuth-specific tests, see:
- `test/controllers/users/omniauth_callbacks_controller_test.rb`
- `test/controllers/connected_accounts_controller_test.rb`
- `test/models/connected_account_test.rb`

## Need Help?

- Check the [Devise](https://github.com/heartcombo/devise) documentation
- Check the [OmniAuth](https://github.com/omniauth/omniauth) documentation
- Review individual provider gem documentation

## License

This OAuth implementation is part of the Rails SaaS Kit and follows the same license.
