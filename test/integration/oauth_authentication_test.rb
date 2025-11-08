require "test_helper"

class OAuthAuthenticationTest < ActionDispatch::IntegrationTest
  def setup
    OmniAuth.config.test_mode = true
  end

  def teardown
    OmniAuth.config.mock_auth[:github] = nil
    OmniAuth.config.mock_auth[:google] = nil
    OmniAuth.config.mock_auth[:facebook] = nil
    OmniAuth.config.mock_auth[:twitter2] = nil
  end

  # GitHub OAuth Tests
  test "sign in with GitHub creates new user and connected account" do
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
      provider: "github",
      uid: "123545",
      info: {
        email: "github@example.com",
        name: "GitHub User"
      },
      credentials: {
        token: "github_token_123"
      }
    })

    assert_difference ["User.count", "ConnectedAccount.count"], 1 do
      post user_github_omniauth_callback_path
    end

    assert_redirected_to root_path
    assert_equal "Successfully authenticated from Github account.", flash[:notice]

    user = User.find_by(email: "github@example.com")
    assert_not_nil user
    assert_equal "GitHub User", user.name
    assert_equal 1, user.connected_accounts.count
    assert_equal "github", user.connected_accounts.first.provider
  end

  test "sign in with GitHub for existing email links account" do
    user = users(:one)

    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
      provider: "github",
      uid: "123545",
      info: {
        email: user.email,
        name: user.name
      },
      credentials: {
        token: "github_token_123"
      }
    })

    assert_no_difference "User.count" do
      assert_difference "ConnectedAccount.count", 1 do
        post user_github_omniauth_callback_path
      end
    end

    assert_redirected_to root_path
    user.reload
    assert_equal 1, user.connected_accounts.where(provider: "github").count
  end

  test "linking GitHub to logged in user" do
    user = users(:one)
    sign_in user

    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
      provider: "github",
      uid: "123545",
      info: {
        email: user.email
      },
      credentials: {
        token: "github_token_123"
      }
    })

    assert_difference "user.connected_accounts.count" do
      post user_github_omniauth_callback_path
    end

    assert_redirected_to root_path
    assert_match /successfully connected/i, flash[:notice]
  end

  # Google OAuth Tests
  test "sign in with Google creates new user" do
    OmniAuth.config.mock_auth[:google] = OmniAuth::AuthHash.new({
      provider: "google_oauth2",
      uid: "987654",
      info: {
        email: "google@example.com",
        name: "Google User"
      },
      credentials: {
        token: "google_token_123"
      }
    })

    assert_difference ["User.count", "ConnectedAccount.count"], 1 do
      post user_google_oauth2_omniauth_callback_path
    end

    user = User.find_by(email: "google@example.com")
    assert_not_nil user
    assert_equal "google_oauth2", user.connected_accounts.first.provider
  end

  # Facebook OAuth Tests
  test "sign in with Facebook creates new user" do
    OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
      provider: "facebook",
      uid: "456789",
      info: {
        email: "facebook@example.com",
        name: "Facebook User"
      },
      credentials: {
        token: "facebook_token_123"
      }
    })

    assert_difference ["User.count", "ConnectedAccount.count"], 1 do
      post user_facebook_omniauth_callback_path
    end

    user = User.find_by(email: "facebook@example.com")
    assert_not_nil user
    assert_equal "facebook", user.connected_accounts.first.provider
  end

  # Twitter OAuth Tests
  test "sign in with Twitter creates new user" do
    OmniAuth.config.mock_auth[:twitter2] = OmniAuth::AuthHash.new({
      provider: "twitter2",
      uid: "111222",
      info: {
        email: "twitter@example.com",
        name: "Twitter User"
      },
      credentials: {
        token: "twitter_token_123"
      }
    })

    assert_difference ["User.count", "ConnectedAccount.count"], 1 do
      post user_twitter2_omniauth_callback_path
    end

    user = User.find_by(email: "twitter@example.com")
    assert_not_nil user
    assert_equal "twitter2", user.connected_accounts.first.provider
  end

  # Error Handling Tests
  test "OAuth failure redirects to sign up with error message" do
    OmniAuth.config.mock_auth[:github] = :invalid_credentials

    post user_github_omniauth_callback_path

    assert_redirected_to new_user_registration_path
    assert_match /authentication failed/i, flash[:alert]
  end

  test "OAuth with missing email shows error" do
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
      provider: "github",
      uid: "123545",
      info: {
        email: nil,
        name: "GitHub User"
      },
      credentials: {
        token: "github_token_123"
      }
    })

    assert_no_difference ["User.count", "ConnectedAccount.count"] do
      post user_github_omniauth_callback_path
    end

    # Should handle missing email gracefully
    assert_response :redirect
  end

  test "cannot link same provider twice" do
    user = users(:one)
    sign_in user

    # Create existing connected account
    user.connected_accounts.create!(
      provider: "github",
      uid: "existing_uid",
      access_token: "token1"
    )

    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
      provider: "github",
      uid: "new_uid",
      info: {
        email: user.email
      },
      credentials: {
        token: "token2"
      }
    })

    # Should either update existing or show error
    post user_github_omniauth_callback_path

    assert_response :redirect
    # User should still only have one GitHub connection
    assert_equal 1, user.connected_accounts.where(provider: "github").count
  end

  test "user can have multiple OAuth providers" do
    user = users(:one)
    sign_in user

    # Link GitHub
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
      provider: "github",
      uid: "123",
      info: { email: user.email },
      credentials: { token: "github_token" }
    })
    post user_github_omniauth_callback_path

    # Link Google
    OmniAuth.config.mock_auth[:google] = OmniAuth::AuthHash.new({
      provider: "google_oauth2",
      uid: "456",
      info: { email: user.email },
      credentials: { token: "google_token" }
    })
    post user_google_oauth2_omniauth_callback_path

    user.reload
    assert_equal 2, user.connected_accounts.count
    assert user.connected_accounts.exists?(provider: "github")
    assert user.connected_accounts.exists?(provider: "google_oauth2")
  end
end
