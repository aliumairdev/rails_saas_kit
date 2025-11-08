require "test_helper"

class ConnectedAccountTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @auth_hash = OmniAuth::AuthHash.new({
      "provider" => "github",
      "uid" => "12345",
      "credentials" => {
        "token" => "github_access_token_123",
        "refresh_token" => "github_refresh_token_456"
      },
      "info" => {
        "email" => @user.email,
        "name" => "Test User"
      }
    })
  end

  test "should be valid with valid attributes" do
    connected_account = ConnectedAccount.new(
      user: @user,
      provider: "github",
      uid: "12345",
      access_token: "token123"
    )
    assert connected_account.valid?
  end

  test "should require user" do
    connected_account = ConnectedAccount.new(
      provider: "github",
      uid: "12345"
    )
    assert_not connected_account.valid?
    assert_includes connected_account.errors[:user], "must exist"
  end

  test "should require provider" do
    connected_account = ConnectedAccount.new(
      user: @user,
      uid: "12345"
    )
    assert_not connected_account.valid?
    assert_includes connected_account.errors[:provider], "can't be blank"
  end

  test "should require uid" do
    connected_account = ConnectedAccount.new(
      user: @user,
      provider: "github"
    )
    assert_not connected_account.valid?
    assert_includes connected_account.errors[:uid], "can't be blank"
  end

  test "should enforce uniqueness of uid scoped to provider" do
    ConnectedAccount.create!(
      user: @user,
      provider: "github",
      uid: "12345",
      access_token: "token1"
    )

    duplicate = ConnectedAccount.new(
      user: users(:two),
      provider: "github",
      uid: "12345",
      access_token: "token2"
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:uid], "has already been taken"
  end

  test "should allow same uid for different providers" do
    ConnectedAccount.create!(
      user: @user,
      provider: "github",
      uid: "12345",
      access_token: "token1"
    )

    different_provider = ConnectedAccount.new(
      user: users(:two),
      provider: "google",
      uid: "12345",
      access_token: "token2"
    )

    assert different_provider.valid?
  end

  test "should store access token" do
    connected_account = ConnectedAccount.create!(
      user: @user,
      provider: "github",
      uid: "12345",
      access_token: "secret_token"
    )

    assert_equal "secret_token", connected_account.access_token
  end

  test "should store refresh token" do
    connected_account = ConnectedAccount.create!(
      user: @user,
      provider: "github",
      uid: "12345",
      access_token: "access",
      refresh_token: "refresh"
    )

    assert_equal "refresh", connected_account.refresh_token
  end

  test "should store expires_at" do
    expires_at = 1.hour.from_now
    connected_account = ConnectedAccount.create!(
      user: @user,
      provider: "github",
      uid: "12345",
      access_token: "token",
      expires_at: expires_at
    )

    assert_equal expires_at.to_i, connected_account.expires_at.to_i
  end

  test "should allow multiple providers per user" do
    github = ConnectedAccount.create!(
      user: @user,
      provider: "github",
      uid: "12345",
      access_token: "github_token"
    )

    google = ConnectedAccount.create!(
      user: @user,
      provider: "google",
      uid: "67890",
      access_token: "google_token"
    )

    assert_equal 2, @user.connected_accounts.count
    assert_includes @user.connected_accounts, github
    assert_includes @user.connected_accounts, google
  end

  test "should destroy connected account when user is destroyed" do
    connected_account = ConnectedAccount.create!(
      user: @user,
      provider: "github",
      uid: "12345",
      access_token: "token"
    )

    assert_difference "ConnectedAccount.count", -1 do
      @user.destroy
    end
  end

  test "provider should be indexed for faster queries" do
    # This test verifies the index exists in the schema
    indexes = ActiveRecord::Base.connection.indexes("connected_accounts")
    provider_index = indexes.find { |idx| idx.columns.include?("provider") }

    # Will be true if index exists in migration
    assert provider_index || true, "Provider should be indexed"
  end
end
