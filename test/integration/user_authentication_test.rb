require "test_helper"

class UserAuthenticationTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
  end

  test "user can sign up with valid information" do
    get new_user_registration_path
    assert_response :success

    assert_difference "User.count", 1 do
      post user_registration_path, params: {
        user: {
          email: "newuser@example.com",
          password: UNIQUE_PASSWORD,
          password_confirmation: UNIQUE_PASSWORD,
          first_name: "New",
          last_name: "User"
        }
      }
    end

    assert_redirected_to root_path
    follow_redirect!

    # User should be created with personal account
    user = User.find_by(email: "newuser@example.com")
    assert user.present?
    assert user.personal_account.present?
    assert_equal "New User", user.personal_account.name
  end

  test "user cannot sign up with invalid email" do
    assert_no_difference "User.count" do
      post user_registration_path, params: {
        user: {
          email: "invalid",
          password: UNIQUE_PASSWORD,
          password_confirmation: UNIQUE_PASSWORD
        }
      }
    end

    assert_response :unprocessable_content
  end

  test "user cannot sign up with mismatched passwords" do
    assert_no_difference "User.count" do
      post user_registration_path, params: {
        user: {
          email: "test@example.com",
          password: UNIQUE_PASSWORD,
          password_confirmation: "different_password"
        }
      }
    end

    assert_response :unprocessable_content
  end

  test "user can log in with valid credentials" do
    post user_session_path, params: {
      user: {
        email: @user.email,
        password: UNIQUE_PASSWORD
      }
    }

    assert_redirected_to authenticated_root_path
    assert user_signed_in?
  end

  test "user cannot log in with invalid password" do
    post user_session_path, params: {
      user: {
        email: @user.email,
        password: "wrong_password"
      }
    }

    assert_response :unprocessable_content
    assert_not user_signed_in?
  end

  test "user with 2FA is redirected to OTP verification" do
    user_2fa = users(:with_2fa)

    post user_session_path, params: {
      user: {
        email: user_2fa.email,
        password: UNIQUE_PASSWORD
      }
    }

    assert_redirected_to users_otp_path
    assert_not user_signed_in? # Not signed in until OTP verified
    assert session[:otp_user_id].present?
  end

  test "user can log out" do
    sign_in @user

    delete destroy_user_session_path
    assert_redirected_to root_path
    assert_not user_signed_in?
  end

  test "unconfirmed user cannot log in" do
    unconfirmed = users(:unconfirmed)

    post user_session_path, params: {
      user: {
        email: unconfirmed.email,
        password: UNIQUE_PASSWORD
      }
    }

    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_select "div[role='alert']", /You have to confirm your email address/
    assert_not user_signed_in?
  end

  test "user can request password reset" do
    post user_password_path, params: {
      user: {
        email: @user.email
      }
    }

    assert_redirected_to new_user_session_path
    assert ActionMailer::Base.deliveries.any? { |mail| mail.to.include?(@user.email) }
  end

  private

  def user_signed_in?
    @user.reload
    warden.authenticated?(:user)
  end

  def warden
    request.env['warden']
  end
end
