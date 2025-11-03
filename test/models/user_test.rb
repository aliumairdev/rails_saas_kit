require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
  end

  # Associations
  test "should have many accounts" do
    assert_respond_to @user, :accounts
  end

  test "should have many owned_accounts" do
    assert_respond_to @user, :owned_accounts
  end

  test "should have many api_tokens" do
    assert_respond_to @user, :api_tokens
  end

  test "should have many notifications" do
    assert_respond_to @user, :notifications
  end

  # Validations
  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "should require email" do
    @user.email = nil
    assert_not @user.valid?
  end

  test "should require unique email" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email
    assert_not duplicate_user.valid?
  end

  # Prefixed IDs
  test "should generate prefixed ID" do
    user = User.create!(
      email: "test@example.com",
      password: UNIQUE_PASSWORD,
      first_name: "Test",
      last_name: "User"
    )
    assert user.prefix_id.start_with?("user_")
  end

  # Name of Person
  test "should have first_name and last_name" do
    assert_equal "John", @user.first_name
    assert_equal "Doe", @user.last_name
  end

  test "should have full_name" do
    assert_equal "John Doe", @user.full_name
  end

  test "full_name should fallback to User if name parts missing" do
    user = User.new(email: "test@example.com")
    assert_equal "User", user.full_name
  end

  # Personal account creation
  test "should create personal account after user creation" do
    user = User.create!(
      email: "newuser@example.com",
      password: UNIQUE_PASSWORD,
      first_name: "New",
      last_name: "User"
    )

    assert user.personal_account.present?
    assert user.personal_account.personal?
    assert_equal "New User", user.personal_account.name
  end

  # Two-Factor Authentication
  test "should generate OTP secret" do
    @user.generate_otp_secret
    assert @user.otp_secret.present?
    assert_equal 32, @user.otp_secret.length
  end

  test "should generate backup codes" do
    codes = @user.generate_otp_backup_codes
    assert_equal 10, codes.length
    assert @user.otp_backup_codes.present?
  end

  test "should enable two factor authentication" do
    backup_codes = @user.enable_two_factor!
    assert_equal 10, backup_codes.length
    assert @user.otp_secret.present?
    assert @user.otp_backup_codes.present?
    assert_not @user.otp_required_for_login? # Not enabled until confirmed
  end

  test "should confirm two factor with valid code" do
    @user.enable_two_factor!
    totp = ROTP::TOTP.new(@user.otp_secret, issuer: "Rails SaaS Kit")
    code = totp.now

    assert @user.confirm_two_factor!(code)
    assert @user.otp_required_for_login?
  end

  test "should not confirm two factor with invalid code" do
    @user.enable_two_factor!
    assert_not @user.confirm_two_factor!("000000")
    assert_not @user.otp_required_for_login?
  end

  test "should verify OTP code" do
    user_with_2fa = users(:with_2fa)
    totp = ROTP::TOTP.new(user_with_2fa.otp_secret, issuer: "Rails SaaS Kit")
    code = totp.now

    assert user_with_2fa.verify_otp_code(code)
  end

  test "should verify backup code" do
    user_with_2fa = users(:with_2fa)
    assert user_with_2fa.verify_otp_backup_code("abcd1234")

    # Code should be removed after use
    assert_not user_with_2fa.reload.otp_backup_codes.include?("abcd1234")
  end

  test "should disable two factor" do
    user_with_2fa = users(:with_2fa)
    user_with_2fa.disable_two_factor!

    assert_not user_with_2fa.otp_required_for_login?
    assert_nil user_with_2fa.otp_secret
    assert_nil user_with_2fa.otp_backup_codes
  end

  # Role helpers
  test "should check if account owner" do
    account = accounts(:personal_one)
    assert @user.account_owner?(account)
  end

  test "should check if account member" do
    account = accounts(:team)
    assert @user.account_member?(account)
  end

  test "should get account role" do
    account = accounts(:personal_one)
    assert_equal "owner", @user.account_role(account)
  end

  # Notification preferences
  test "should enable email notifications by default" do
    assert @user.email_notifications_enabled?
  end

  test "should enable in-app notifications by default" do
    assert @user.in_app_notifications_enabled?
  end
end
