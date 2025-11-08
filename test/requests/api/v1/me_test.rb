require "test_helper"

class Api::V1::MeTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @token = @user.api_tokens.create!(name: "Test Token")
  end

  test "get current user with valid token returns success" do
    get api_v1_me_url, headers: {
      "Authorization" => "Bearer #{@token.token}"
    }, as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal @user.id, json["id"]
    assert_equal @user.email, json["email"]
    assert_equal @user.first_name, json["first_name"]
    assert_equal @user.last_name, json["last_name"]
  end

  test "get current user without authorization returns unauthorized" do
    get api_v1_me_url, as: :json

    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_includes json["error"], "authorization"
  end

  test "get current user with invalid token returns unauthorized" do
    get api_v1_me_url, headers: {
      "Authorization" => "Bearer invalid_token_12345"
    }, as: :json

    assert_response :unauthorized
  end

  test "get current user with expired token returns unauthorized" do
    expired_token = @user.api_tokens.create!(
      name: "Expired Token",
      expires_at: 1.day.ago
    )

    get api_v1_me_url, headers: {
      "Authorization" => "Bearer #{expired_token.token}"
    }, as: :json

    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_includes json["error"].downcase, "expired"
  end

  test "get current user updates token last_used_at" do
    assert_nil @token.last_used_at

    get api_v1_me_url, headers: {
      "Authorization" => "Bearer #{@token.token}"
    }, as: :json

    assert_response :success
    @token.reload
    assert_not_nil @token.last_used_at
    assert @token.last_used_at > 1.minute.ago
  end

  test "get current user with malformed authorization header returns unauthorized" do
    get api_v1_me_url, headers: {
      "Authorization" => "InvalidFormat token123"
    }, as: :json

    assert_response :unauthorized
  end

  test "get current user includes account information" do
    get api_v1_me_url, headers: {
      "Authorization" => "Bearer #{@token.token}"
    }, as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert json.key?("accounts")
    assert json["accounts"].is_a?(Array)
  end
end
