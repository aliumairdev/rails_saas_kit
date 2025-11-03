require "test_helper"

class ApiTokenTest < ActiveSupport::TestCase
  def setup
    @api_token = api_tokens(:one)
  end

  # Associations
  test "should belong to user" do
    assert_equal users(:one), @api_token.user
  end

  # Validations
  test "should be valid with valid attributes" do
    assert @api_token.valid?
  end

  test "should require name" do
    @api_token.name = nil
    assert_not @api_token.valid?
  end

  test "should require token" do
    @api_token.token = nil
    assert_not @api_token.valid?
  end

  test "should require unique token" do
    duplicate_token = ApiToken.new(
      user: users(:two),
      name: "Duplicate",
      token: @api_token.token
    )
    assert_not duplicate_token.valid?
  end

  # Prefixed IDs
  test "should generate prefixed ID" do
    token = ApiToken.create!(
      user: users(:one),
      name: "Test Token"
    )
    assert token.prefix_id.start_with?("token_")
  end

  # Token generation
  test "should generate token on creation" do
    token = ApiToken.create!(
      user: users(:one),
      name: "New Token"
    )

    assert token.token.present?
    assert token.plain_token.present? # Available only after creation
  end

  test "should hash token before saving" do
    token = ApiToken.new(user: users(:one), name: "Test")
    plain_token = SecureRandom.urlsafe_base64(32)
    token.instance_variable_set(:@plain_token, plain_token)
    token.token = ApiToken.hash_token(plain_token)
    token.save!

    # Token should be hashed
    assert_not_equal plain_token, token.token
    assert_equal 64, token.token.length # SHA256 hex digest length
  end

  # Scopes
  test "active scope should return non-expired tokens" do
    active_tokens = ApiToken.active
    assert_includes active_tokens, api_tokens(:one)
    assert_not_includes active_tokens, api_tokens(:expired)
  end

  test "expired scope should return expired tokens" do
    expired_tokens = ApiToken.expired
    assert_includes expired_tokens, api_tokens(:expired)
    assert_not_includes expired_tokens, api_tokens(:one)
  end

  # Class methods
  test "find_by_token should find token by plain text" do
    token = ApiToken.find_by_token("test_token_one")
    assert_equal api_tokens(:one), token
  end

  test "find_by_token should return nil for invalid token" do
    token = ApiToken.find_by_token("invalid_token")
    assert_nil token
  end

  test "find_by_token should return nil for expired token" do
    # Expired token exists but should not be returned by active scope
    token = ApiToken.find_by_token("expired_token")
    assert_nil token # Because find_by_token uses active scope
  end

  test "hash_token should consistently hash tokens" do
    plain = "test_token"
    hash1 = ApiToken.hash_token(plain)
    hash2 = ApiToken.hash_token(plain)

    assert_equal hash1, hash2
    assert_equal 64, hash1.length
  end

  # Instance methods
  test "expired? should check expiration" do
    assert_not @api_token.expired?
    assert api_tokens(:expired).expired?
  end

  test "active? should be opposite of expired?" do
    assert @api_token.active?
    assert_not api_tokens(:expired).active?
  end

  test "mark_as_used! should update last_used_at" do
    old_time = @api_token.last_used_at
    travel 1.hour do
      @api_token.mark_as_used!
    end

    assert @api_token.reload.last_used_at > old_time
  end

  test "plain_token should be available after creation" do
    token = ApiToken.create!(user: users(:one), name: "Test")
    assert token.plain_token.present?

    # But not after reload
    token.reload
    assert_nil token.plain_token
  end
end
