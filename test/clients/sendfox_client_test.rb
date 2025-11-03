require "test_helper"

class SendfoxClientTest < ActiveSupport::TestCase
  setup do
    @client = SendfoxClient.new(token: "test_token")
    @base_url = "https://api.sendfox.com"
  end

  test "me returns user information" do
    stub_request(:get, "#{@base_url}/me")
      .with(headers: { "Authorization" => "Bearer test_token" })
      .to_return(
        status: 200,
        body: { id: 1, email: "test@example.com" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    response = @client.me

    assert_equal 1, response["id"]
    assert_equal "test@example.com", response["email"]
  end

  test "lists returns array of lists" do
    stub_request(:get, "#{@base_url}/lists")
      .to_return(
        status: 200,
        body: { data: [{ id: 1, name: "Test List" }] }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    response = @client.lists

    assert_equal 1, response["data"].first["id"]
    assert_equal "Test List", response["data"].first["name"]
  end

  test "create_list creates a new list" do
    stub_request(:post, "#{@base_url}/lists")
      .with(body: { name: "New List" }.to_json)
      .to_return(
        status: 201,
        body: { id: 2, name: "New List" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    response = @client.create_list(name: "New List")

    assert_equal 2, response["id"]
    assert_equal "New List", response["name"]
  end

  test "contacts with email filter makes request with query param" do
    stub_request(:get, "#{@base_url}/contacts?email=test@example.com")
      .to_return(
        status: 200,
        body: { data: [{ id: 1, email: "test@example.com" }] }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    response = @client.contacts(email: "test@example.com")

    assert_equal 1, response["data"].first["id"]
    assert_equal "test@example.com", response["data"].first["email"]
  end

  test "create_contact creates a new contact" do
    stub_request(:post, "#{@base_url}/contacts")
      .with(
        body: {
          email: "new@example.com",
          first_name: "John",
          last_name: "Doe"
        }.to_json
      )
      .to_return(
        status: 201,
        body: {
          id: 1,
          email: "new@example.com",
          first_name: "John",
          last_name: "Doe"
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    response = @client.create_contact(
      email: "new@example.com",
      first_name: "John",
      last_name: "Doe"
    )

    assert_equal 1, response["id"]
    assert_equal "new@example.com", response["email"]
  end

  test "remove_contact makes DELETE request" do
    stub_request(:delete, "#{@base_url}/lists/1/contacts/2")
      .to_return(
        status: 204,
        body: "",
        headers: {}
      )

    # DELETE requests typically return empty response
    @client.remove_contact(list_id: 1, contact_id: 2)

    # If we get here without an exception, the request was successful
    assert true
  end

  test "handles API errors gracefully" do
    stub_request(:get, "#{@base_url}/lists")
      .to_return(
        status: 401,
        body: { error: "Unauthorized" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    error = assert_raises(StandardError) do
      @client.lists
    end

    assert_match /401/, error.message
    assert_match /Unauthorized/, error.message
  end
end
