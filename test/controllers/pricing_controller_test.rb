require "test_helper"

class PricingControllerTest < ActionDispatch::IntegrationTest
  test "should get pricing page" do
    get pricing_path
    assert_response :success
  end

  test "pricing page should display visible plans" do
    get pricing_path
    assert_response :success

    # Should show visible plans
    assert_select "h3", text: "Free"
    assert_select "h3", text: "Starter"
    assert_select "h3", text: "Pro"
    assert_select "h3", text: "Enterprise"

    # Should not show hidden plans
    assert_select "h3", { text: "Legacy Plan", count: 0 }
  end

  test "pricing page should show plan features" do
    get pricing_path
    assert_response :success

    # Check for feature displays
    assert_match /review requests/, response.body
    assert_match /campaigns/, response.body
  end

  test "pricing page should have appropriate CTAs for non-authenticated users" do
    get pricing_path
    assert_response :success

    # Should have "Get started" links that point to registration
    assert_select "a[href='#{new_user_registration_path}']", text: "Get started"
  end

  test "pricing page should have appropriate CTAs for authenticated users without account" do
    user = users(:one)
    sign_in user
    Current.account = nil

    get pricing_path
    assert_response :success

    # Should have links to create new account
    assert_select "a[href='#{new_account_path}']"
  end

  test "pricing page should have plan selection links for authenticated users with account" do
    user = users(:one)
    account = accounts(:personal_one)
    sign_in_with_account(user, account: account)

    get pricing_path
    assert_response :success

    # Should have links to billing with plan selection
    assert_select "a[href*='#{account_billing_path(account)}']"
  end
end
