require "test_helper"

class Api::V1::AuthenticationTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @user.update(password: "password123", password_confirmation: "password123")
  end

  test "authenticate with valid credentials returns success" do
    post api_v1_auth_url, params: {
      email: @user.email,
      password: "password123"
    }, as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_not_nil json["token"]
    assert_equal @user.email, json["user"]["email"]
  end

  test "authenticate with invalid email returns unauthorized" do
    post api_v1_auth_url, params: {
      email: "nonexistent@example.com",
      password: "password123"
    }, as: :json

    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_includes json["error"], "Invalid"
  end

  test "authenticate with invalid password returns unauthorized" do
    post api_v1_auth_url, params: {
      email: @user.email,
      password: "wrongpassword"
    }, as: :json

    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_includes json["error"], "Invalid"
  end

  test "authenticate without email returns bad request" do
    post api_v1_auth_url, params: {
      password: "password123"
    }, as: :json

    assert_response :bad_request
  end

  test "authenticate without password returns bad request" do
    post api_v1_auth_url, params: {
      email: @user.email
    }, as: :json

    assert_response :bad_request
  end

  test "authenticate with unconfirmed user returns unauthorized" do
    unconfirmed_user = users(:unconfirmed)
    unconfirmed_user.update(password: "password123", password_confirmation: "password123")

    post api_v1_auth_url, params: {
      email: unconfirmed_user.email,
      password: "password123"
    }, as: :json

    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_includes json["error"].downcase, "confirm"
  end
end
