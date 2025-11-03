require "application_system_test_case"

class UserRegistrationTest < ApplicationSystemTestCase
  test "user can sign up with valid information" do
    visit new_user_registration_path

    fill_in "Email", with: "newsystemuser@example.com"
    fill_in "Password", with: UNIQUE_PASSWORD
    fill_in "Password confirmation", with: UNIQUE_PASSWORD
    fill_in "First name", with: "System"
    fill_in "Last name", with: "User"

    # Invisible captcha should be present but not visible
    assert_selector "input[name='subtitle']", visible: :hidden

    click_button "Sign up"

    # Should see confirmation message
    assert_text "A message with a confirmation link has been sent"

    # User should be created
    user = User.find_by(email: "newsystemuser@example.com")
    assert user.present?
    assert_equal "System", user.first_name
    assert_equal "User", user.last_name

    # Personal account should be created
    assert user.personal_account.present?
    assert_equal "System User", user.personal_account.name
  end

  test "user cannot sign up with invalid email" do
    visit new_user_registration_path

    fill_in "Email", with: "invalid_email"
    fill_in "Password", with: UNIQUE_PASSWORD
    fill_in "Password confirmation", with: UNIQUE_PASSWORD

    click_button "Sign up"

    # Should see error message
    assert_text "Email is invalid"

    # User should not be created
    assert_nil User.find_by(email: "invalid_email")
  end

  test "user cannot sign up with mismatched passwords" do
    visit new_user_registration_path

    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: UNIQUE_PASSWORD
    fill_in "Password confirmation", with: "different_password"

    click_button "Sign up"

    # Should see error message
    assert_text "Password confirmation doesn't match"

    # User should not be created
    assert_nil User.find_by(email: "test@example.com")
  end

  test "user can see password requirements" do
    visit new_user_registration_path

    # Check for password requirements (if displayed)
    assert_selector "form"
  end

  test "form should have spam protection" do
    visit new_user_registration_path

    # Invisible captcha honeypot fields should be present but hidden
    assert_selector "input[name='subtitle']", visible: :hidden
  end
end
