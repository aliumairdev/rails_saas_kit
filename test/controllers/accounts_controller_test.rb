require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = accounts(:personal_one)
    @team_account = accounts(:team)
    sign_in @user
  end

  # Index tests
  test "should get index" do
    get accounts_path
    assert_response :success
  end

  test "index should display user's accounts" do
    get accounts_path
    assert_response :success
    assert_select "h1", text: "Your Accounts"
  end

  # New tests
  test "should get new" do
    get new_account_path
    assert_response :success
  end

  # Create tests
  test "should create account" do
    assert_difference("Account.count") do
      post accounts_path, params: {
        account: {
          name: "New Test Account"
        }
      }
    end

    assert_redirected_to account_path(Account.last)
    assert_equal "Account created successfully!", flash[:notice]
  end

  test "should not create account with invalid data" do
    assert_no_difference("Account.count") do
      post accounts_path, params: {
        account: {
          name: ""
        }
      }
    end

    assert_response :unprocessable_content
  end

  # Show tests
  test "should show account" do
    get account_path(@account)
    assert_response :success
    assert_select "h1", text: @account.name
  end

  test "should not show account user doesn't belong to" do
    other_account = accounts(:admin_account)
    get account_path(other_account)
    assert_redirected_to accounts_path
    assert_equal "Account not found.", flash[:alert]
  end

  # Edit tests
  test "should get edit for owned account" do
    get edit_account_path(@team_account)
    assert_response :success
  end

  # Update tests
  test "should update account" do
    patch account_path(@team_account), params: {
      account: {
        name: "Updated Team Name",
        billing_email: "billing@test.com"
      }
    }

    assert_redirected_to account_path(@team_account)
    @team_account.reload
    assert_equal "Updated Team Name", @team_account.name
    assert_equal "billing@test.com", @team_account.billing_email
    assert_equal "Account updated successfully!", flash[:notice]
  end

  test "should not update account with invalid data" do
    patch account_path(@team_account), params: {
      account: {
        name: ""
      }
    }

    assert_response :unprocessable_content
  end

  # Switch tests
  test "should switch account" do
    post switch_account_path(@team_account)
    assert_redirected_to dashboard_path
    assert_equal "Switched to #{@team_account.name}", flash[:notice]
  end

  # Destroy tests
  test "should destroy team account" do
    team_to_delete = Account.create!(name: "Delete Me", owner: @user, personal: false)
    team_to_delete.account_users.create!(user: @user)

    assert_difference("Account.count", -1) do
      delete account_path(team_to_delete)
    end

    assert_redirected_to accounts_path
    assert_match /was successfully deleted/, flash[:notice]
  end

  test "should not destroy personal account" do
    assert_no_difference("Account.count") do
      delete account_path(@account)
    end

    # Policy prevents deletion, which raises Pundit::NotAuthorizedError
    # This gets caught and redirects to root
    assert_response :redirect
  end

  test "should switch to another account before deleting current account" do
    # Set team account as current
    Current.account = @team_account

    # Create another account to switch to
    other_account = Account.create!(name: "Other Account", owner: @user, personal: false)
    other_account.account_users.create!(user: @user)

    delete account_path(@team_account)

    assert_redirected_to accounts_path
    # Current account should have changed
    assert_not_equal @team_account.id, Current.account&.id
  end

  # Logo upload tests
  test "should update account with logo" do
    file = fixture_file_upload("test_image.png", "image/png")

    patch account_path(@team_account), params: {
      account: {
        logo: file
      }
    }

    assert_redirected_to account_path(@team_account)
    @team_account.reload
    assert @team_account.logo.attached?
  end
end
