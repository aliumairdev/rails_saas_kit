require "test_helper"

class AccountInvitationTest < ActiveSupport::TestCase
  def setup
    @invitation = account_invitations(:pending)
  end

  # Associations
  test "should belong to account" do
    assert_respond_to @invitation, :account
    assert_instance_of Account, @invitation.account
  end

  test "should belong to invited_by user" do
    assert_respond_to @invitation, :invited_by
    assert_instance_of User, @invitation.invited_by
  end

  # Validations
  test "should be valid with valid attributes" do
    assert @invitation.valid?
  end

  test "should require email" do
    @invitation.email = nil
    assert_not @invitation.valid?
    assert_includes @invitation.errors[:email], "can't be blank"
  end

  test "should validate email format" do
    @invitation.email = "invalid"
    assert_not @invitation.valid?
    assert_includes @invitation.errors[:email], "is invalid"

    @invitation.email = "valid@example.com"
    assert @invitation.valid?
  end

  test "should require name" do
    @invitation.name = nil
    assert_not @invitation.valid?
    assert_includes @invitation.errors[:name], "can't be blank"
  end

  test "should require unique email per account" do
    duplicate = AccountInvitation.new(
      account: @invitation.account,
      email: @invitation.email,
      name: "Duplicate User",
      invited_by: @invitation.invited_by
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been invited to this account"
  end

  test "should allow same email for different accounts" do
    different_account = accounts(:team_two)
    invitation = AccountInvitation.new(
      account: different_account,
      email: @invitation.email,
      name: "Same Email Different Account",
      invited_by: users(:one)
    )
    assert invitation.valid?
  end

  # Callbacks
  test "should generate token on create" do
    invitation = AccountInvitation.new(
      account: accounts(:team),
      email: "newuser@example.com",
      name: "New User",
      invited_by: users(:one)
    )
    assert_nil invitation.token

    invitation.save!
    assert_not_nil invitation.token
    assert invitation.token.length > 20
  end

  test "should set expires_at on create" do
    invitation = AccountInvitation.create!(
      account: accounts(:team),
      email: "newuser2@example.com",
      name: "New User 2",
      invited_by: users(:one)
    )

    assert_not_nil invitation.expires_at
    assert invitation.expires_at > Time.current
    assert invitation.expires_at < (AccountInvitation::EXPIRATION_DAYS + 1).days.from_now
  end

  test "should not override existing token" do
    invitation = AccountInvitation.new(
      account: accounts(:team),
      email: "test@example.com",
      name: "Test",
      invited_by: users(:one),
      token: "custom_token"
    )
    invitation.save!

    assert_equal "custom_token", invitation.token
  end

  # Scopes
  test "pending scope should return pending invitations" do
    pending_invitations = AccountInvitation.pending
    assert pending_invitations.all? { |i| i.pending? }
    assert_includes pending_invitations, account_invitations(:pending)
  end

  test "expired scope should return expired invitations" do
    expired_invitations = AccountInvitation.expired
    assert expired_invitations.all? { |i| i.expired? }
    assert_includes expired_invitations, account_invitations(:expired)
  end

  test "accepted scope should return accepted invitations" do
    accepted_invitations = AccountInvitation.accepted
    assert accepted_invitations.all? { |i| i.accepted? }
    assert_includes accepted_invitations, account_invitations(:accepted)
  end

  # Instance methods
  test "expired? should return true for expired invitations" do
    @invitation.expires_at = 1.day.ago
    @invitation.accepted_at = nil
    assert @invitation.expired?
  end

  test "expired? should return false for non-expired invitations" do
    @invitation.expires_at = 1.day.from_now
    @invitation.accepted_at = nil
    assert_not @invitation.expired?
  end

  test "expired? should return false for accepted invitations" do
    @invitation.expires_at = 1.day.ago
    @invitation.accepted_at = Time.current
    assert_not @invitation.expired?
  end

  test "accepted? should return true when accepted_at is present" do
    @invitation.accepted_at = Time.current
    assert @invitation.accepted?
  end

  test "accepted? should return false when accepted_at is nil" do
    @invitation.accepted_at = nil
    assert_not @invitation.accepted?
  end

  test "pending? should return true for non-expired, non-accepted invitations" do
    @invitation.accepted_at = nil
    @invitation.expires_at = 1.day.from_now
    assert @invitation.pending?
  end

  test "pending? should return false for expired invitations" do
    @invitation.accepted_at = nil
    @invitation.expires_at = 1.day.ago
    assert_not @invitation.pending?
  end

  test "pending? should return false for accepted invitations" do
    @invitation.accepted_at = Time.current
    assert_not @invitation.pending?
  end

  test "accept! should create account_user and mark as accepted" do
    # Use admin user who is not a member of the team account
    user = users(:admin)
    pending_invitation = account_invitations(:pending)

    # Verify user is not already a member
    existing_membership = AccountUser.find_by(account: pending_invitation.account, user: user)
    assert_nil existing_membership, "User should not already be a member"

    assert_difference "AccountUser.count", 1 do
      assert pending_invitation.accept!(user)
    end

    assert_not_nil pending_invitation.reload.accepted_at
    assert pending_invitation.accepted?

    # Verify AccountUser was created
    account_user = AccountUser.find_by(account: pending_invitation.account, user: user)
    assert_not_nil account_user
  end

  test "accept! should not accept expired invitation" do
    expired_invitation = account_invitations(:expired)
    user = users(:two)

    assert_no_difference "AccountUser.count" do
      assert_equal false, expired_invitation.accept!(user)
    end

    assert_nil expired_invitation.reload.accepted_at
  end

  test "accept! should not accept already accepted invitation" do
    accepted_invitation = account_invitations(:accepted)
    user = users(:admin)

    assert_no_difference "AccountUser.count" do
      assert_equal false, accepted_invitation.accept!(user)
    end
  end

  test "role getter should return role from roles hash" do
    @invitation.roles = { "role" => "admin" }
    assert_equal "admin", @invitation.role
  end

  test "role getter should default to member" do
    @invitation.roles = {}
    assert_equal "member", @invitation.role
  end

  test "role setter should set role in roles hash" do
    @invitation.role = "admin"
    assert_equal({ "role" => "admin" }, @invitation.roles)
  end
end
