require "test_helper"

class AccountUserTest < ActiveSupport::TestCase
  def setup
    @account_user = account_users(:one_personal)
  end

  # Associations
  test "should belong to account" do
    assert_respond_to @account_user, :account
    assert_instance_of Account, @account_user.account
  end

  test "should belong to user" do
    assert_respond_to @account_user, :user
    assert_instance_of User, @account_user.user
  end

  # Validations
  test "should be valid with valid attributes" do
    assert @account_user.valid?
  end

  test "should require unique user per account" do
    duplicate = AccountUser.new(
      account: @account_user.account,
      user: @account_user.user
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  test "should allow same user in different accounts" do
    # Create a new account to avoid fixture conflicts
    different_account = Account.create!(name: "Test Account", owner: users(:two))
    account_user = AccountUser.new(
      account: different_account,
      user: @account_user.user # user one (not a member of the new account)
    )
    assert account_user.valid?, "Same user should be allowed in different accounts. Errors: #{account_user.errors.full_messages}"
  end

  # Role helpers
  test "admin? should return true when user has admin role" do
    @account_user.roles = { "admin" => true }
    assert @account_user.admin?
  end

  test "admin? should return false when user does not have admin role" do
    @account_user.roles = {}
    assert_not @account_user.admin?
  end

  test "owner? should return true when user has owner role" do
    @account_user.roles = { "owner" => true }
    assert @account_user.owner?
  end

  test "member? should return true when user has member role" do
    @account_user.roles = { "member" => true }
    assert @account_user.member?
  end

  test "has_role? should check for specific role" do
    @account_user.roles = { "admin" => true, "member" => true }
    assert @account_user.has_role?("admin")
    assert @account_user.has_role?("member")
    assert_not @account_user.has_role?("owner")
  end

  test "add_role should add valid role" do
    @account_user.roles = {}
    assert @account_user.add_role("admin")
    assert @account_user.admin?
  end

  test "add_role should not add invalid role" do
    result = @account_user.add_role("invalid_role")
    assert_equal false, result
    assert_not @account_user.has_role?("invalid_role")
  end

  test "add_role should save changes" do
    @account_user.roles = {}
    @account_user.add_role("admin")
    @account_user.reload
    assert @account_user.admin?
  end

  test "remove_role should remove existing role" do
    @account_user.roles = { "admin" => true }
    @account_user.save!

    assert @account_user.remove_role("admin")
    assert_not @account_user.admin?
  end

  test "remove_role should not remove invalid role" do
    result = @account_user.remove_role("invalid_role")
    assert_equal false, result
  end

  test "role_names should return array of role names" do
    @account_user.roles = { "admin" => true, "member" => true, "disabled" => false }
    role_names = @account_user.role_names

    assert_includes role_names, "admin"
    assert_includes role_names, "member"
    assert_not_includes role_names, "disabled"
  end

  test "ROLES constant should include valid roles" do
    assert_includes AccountUser::ROLES, "owner"
    assert_includes AccountUser::ROLES, "admin"
    assert_includes AccountUser::ROLES, "member"
  end

  # Counter cache
  test "creating account_user should increment account counter" do
    account = accounts(:team)
    initial_count = account.account_users_count || 0

    assert_difference -> { account.reload.account_users_count }, 1 do
      AccountUser.create!(
        account: account,
        user: users(:admin)
      )
    end
  end

  test "destroying account_user should decrement account counter" do
    account = @account_user.account
    initial_count = account.account_users_count

    assert_difference -> { account.reload.account_users_count }, -1 do
      @account_user.destroy
    end
  end
end
