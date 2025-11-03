require "test_helper"

class AccountTest < ActiveSupport::TestCase
  def setup
    @account = accounts(:personal_one)
  end

  # Associations
  test "should belong to owner" do
    assert_equal users(:one), @account.owner
  end

  test "should have many users" do
    assert_respond_to @account, :users
  end

  test "should have many account_invitations" do
    assert_respond_to @account, :account_invitations
  end

  # Validations
  test "should be valid with valid attributes" do
    assert @account.valid?
  end

  test "should require name" do
    @account.name = nil
    assert_not @account.valid?
  end

  test "should have unique subdomain" do
    account1 = Account.create!(name: "Test 1", owner: users(:one), subdomain: "test")
    account2 = Account.new(name: "Test 2", owner: users(:two), subdomain: "test")
    assert_not account2.valid?
  end

  # Prefixed IDs
  test "should generate prefixed ID" do
    account = Account.create!(name: "Test Account", owner: users(:one))
    assert account.prefix_id.start_with?("acct_")
  end

  # Scopes
  test "personal scope should return personal accounts" do
    personal_accounts = Account.personal
    assert personal_accounts.all?(&:personal?)
  end

  test "team scope should return team accounts" do
    team_accounts = Account.team
    assert team_accounts.none?(&:personal?)
  end

  # Member checks
  test "should check if user is member" do
    assert @account.member?(users(:one))
  end

  test "should check if user is owner" do
    assert @account.owner?(users(:one))
    assert_not @account.owner?(users(:two))
  end

  # Subscription helpers (mocked)
  test "should respond to subscription methods" do
    assert_respond_to @account, :subscribed?
    assert_respond_to @account, :on_trial?
    assert_respond_to @account, :subscription
  end
end
