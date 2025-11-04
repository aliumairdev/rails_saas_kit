## API Clients

Rails SaaS Kit includes a built-in API client generator to help you create your own API clients for integrations with any third-party API.

### Why Build Your Own API Clients?

As developers, it's easy to reach for Ruby gems, but each dependency adds maintenance burden to your application. We've found that most API gems eventually need to be forked to fix bugs or implement missing features.

**Benefits of building your own API clients:**

✅ **Easy to maintain** - You control the code
✅ **No external breaking changes** - Updates won't break your app
✅ **Only what you need** - Implement just the features you use
✅ **Better understanding** - Know exactly how your integrations work
✅ **No dependency bloat** - Keep your Gemfile lean

## Table of Contents

- [Quick Start](#quick-start)
- [Creating API Clients](#creating-api-clients)
- [Using API Clients](#using-api-clients)
- [ApplicationClient Base Class](#applicationclient-base-class)
- [Testing API Clients](#testing-api-clients)
- [Examples](#examples)
- [Advanced Usage](#advanced-usage)

## Quick Start

### 1. Generate an API Client

```bash
rails g api_client Stripe
```

This creates:
- `app/clients/stripe_client.rb` - The client class
- `test/clients/stripe_client_test.rb` - Test file

### 2. Implement API Methods

```ruby
class StripeClient < ApplicationClient
  BASE_URI = "https://api.stripe.com/v1"

  def customers
    get "/customers"
  end

  def create_customer(email:, name:)
    post "/customers", body: { email: email, name: name }
  end
end
```

### 3. Use the Client

```ruby
client = StripeClient.new(token: "sk_test_...")
customers = client.customers
customer = client.create_customer(email: "user@example.com", name: "John Doe")
```

## Creating API Clients

### Basic Generation

Generate a basic API client:

```bash
rails g api_client OpenAi
```

Creates:
```
app/clients/open_ai_client.rb
test/clients/open_ai_client_test.rb
```

### With Base URL

Specify the API base URL:

```bash
rails g api_client OpenAi --url https://api.openai.com/v1
```

Generated client:
```ruby
class OpenAiClient < ApplicationClient
  BASE_URI = "https://api.openai.com/v1"
  # ...
end
```

### With Pre-defined Methods

Generate a client with common CRUD methods:

```bash
rails g api_client OpenAi completions:create embeddings:create models:index --url https://api.openai.com/v1
```

This generates a client with these methods already stubbed out:
- `completions` (create type → POST request)
- `embeddings` (create type → POST request)
- `models` (index type → GET request)

### Method Types

When using the `--methods` option, you can specify method types:

| Type | HTTP Method | Use Case | Example |
|------|-------------|----------|---------|
| `index` | GET | List resources | `users:index` |
| `show` | GET | Get single resource | `user:show` |
| `create` | POST | Create resource | `user:create` |
| `update` | PUT | Update resource | `user:update` |
| `destroy` | DELETE | Delete resource | `user:destroy` |

**Example:**

```bash
rails g api_client Github repos:index repo:show create_repo:create --url https://api.github.com
```

## Using API Clients

### Initialization

All API clients accept a `token` parameter for authorization:

```ruby
# With API token
client = SendfoxClient.new(token: "your_api_token")

# Without token (for public APIs)
client = PublicApiClient.new
```

### Making Requests

#### GET Requests

```ruby
# Simple GET
response = client.get("/users")

# GET with query parameters
response = client.get("/users", params: { page: 2, per_page: 50 })
```

#### POST Requests

```ruby
# POST with body
response = client.post("/users", body: {
  name: "John Doe",
  email: "john@example.com"
})
```

#### PUT/PATCH Requests

```ruby
# Update resource
response = client.put("/users/123", body: {
  name: "Jane Doe"
})

# Partial update
response = client.patch("/users/123", body: {
  email: "newemail@example.com"
})
```

#### DELETE Requests

```ruby
# Delete resource
response = client.delete("/users/123")

# Delete with parameters
response = client.delete("/users/123", params: { force: true })
```

### Custom Request Options

Pass custom options to any request:

```ruby
response = client.get("/users",
  headers: {
    "Custom-Header" => "value"
  },
  timeout: 60
)
```

## ApplicationClient Base Class

All API clients inherit from `ApplicationClient`, which provides:

### HTTP Methods

- `get(path, params: {}, **options)` - GET request
- `post(path, body: {}, **options)` - POST request
- `put(path, body: {}, **options)` - PUT request
- `patch(path, body: {}, **options)` - PATCH request
- `delete(path, params: {}, **options)` - DELETE request

### Features

#### 1. Automatic Authorization

Bearer token is automatically added to requests:

```ruby
client = StripeClient.new(token: "sk_test_...")
# Adds header: Authorization: Bearer sk_test_...
client.get("/customers")
```

#### 2. JSON Parsing

Responses are automatically parsed from JSON:

```ruby
response = client.get("/users")
# Returns Ruby hash/array, not raw JSON string
response["data"].first["name"] # => "John Doe"
```

#### 3. Error Handling

HTTP errors are automatically caught and raised:

```ruby
begin
  client.get("/invalid-endpoint")
rescue StandardError => e
  puts e.message # => "HTTP 404: Not Found"
end
```

#### 4. Configurable Defaults

Default options include:

```ruby
{
  headers: {
    "Content-Type" => "application/json",
    "Accept" => "application/json"
  },
  timeout: 30,
  format: :json
}
```

### Customizing ApplicationClient

Override methods to customize behavior:

```ruby
class MyApiClient < ApplicationClient
  # Custom error handling
  def handle_error(response)
    case response.code
    when 429
      raise "Rate limit exceeded. Retry after #{response.headers['Retry-After']} seconds"
    else
      super
    end
  end

  # Custom response parsing (e.g., XML)
  def parse_response(response)
    return Nokogiri::XML(response.body) if response.headers['Content-Type'].include?('xml')
    super
  end

  # Custom default options
  def default_options
    super.deep_merge({
      headers: {
        "X-Custom-Header" => "value"
      },
      timeout: 60
    })
  end
end
```

## Testing API Clients

The Rails SaaS Kit uses WebMock for testing HTTP interactions.

### Basic Test Structure

```ruby
require "test_helper"

class MyApiClientTest < ActiveSupport::TestCase
  setup do
    @client = MyApiClient.new(token: "test_token")
  end

  test "method_name makes correct request" do
    # Stub the HTTP request
    stub_request(:get, "https://api.example.com/resource")
      .with(headers: { "Authorization" => "Bearer test_token" })
      .to_return(
        status: 200,
        body: { id: 1, name: "Test" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    # Call the method
    response = @client.resource

    # Assert response
    assert_equal 1, response["id"]
    assert_equal "Test", response["name"]
  end
end
```

### Stubbing Requests

#### GET Request

```ruby
stub_request(:get, "https://api.example.com/users")
  .to_return(
    status: 200,
    body: [{ id: 1, name: "John" }].to_json
  )
```

#### POST Request with Body

```ruby
stub_request(:post, "https://api.example.com/users")
  .with(
    body: { name: "John", email: "john@example.com" }.to_json,
    headers: { "Content-Type" => "application/json" }
  )
  .to_return(
    status: 201,
    body: { id: 1, name: "John" }.to_json
  )
```

#### Request with Query Parameters

```ruby
stub_request(:get, "https://api.example.com/users?page=2&per_page=50")
  .to_return(
    status: 200,
    body: { data: [] }.to_json
  )
```

#### Testing Error Handling

```ruby
test "handles 401 errors" do
  stub_request(:get, "https://api.example.com/protected")
    .to_return(
      status: 401,
      body: { error: "Unauthorized" }.to_json
    )

  error = assert_raises(StandardError) do
    @client.protected_resource
  end

  assert_match /401/, error.message
  assert_match /Unauthorized/, error.message
end
```

### Advanced Test Patterns

#### Testing Headers

```ruby
test "sends correct headers" do
  stub = stub_request(:get, "https://api.example.com/users")
    .with(headers: {
      "Authorization" => "Bearer test_token",
      "X-Custom-Header" => "value"
    })

  @client.users

  assert_requested stub
end
```

#### Testing Multiple Requests

```ruby
test "makes multiple requests" do
  stub_request(:get, "https://api.example.com/users/1")
    .to_return(body: { id: 1 }.to_json)

  stub_request(:get, "https://api.example.com/users/2")
    .to_return(body: { id: 2 }.to_json)

  user1 = @client.user(1)
  user2 = @client.user(2)

  assert_equal 1, user1["id"]
  assert_equal 2, user2["id"]
end
```

## Examples

### Example 1: Sendfox Email Marketing API

```ruby
class SendfoxClient < ApplicationClient
  BASE_URI = "https://api.sendfox.com"

  def me
    get "/me"
  end

  def lists
    get "/lists"
  end

  def create_list(name:)
    post "/lists", body: { name: name }
  end

  def contacts(email: nil)
    if email
      get "/contacts", params: { email: email }
    else
      get "/contacts"
    end
  end

  def create_contact(**params)
    post "/contacts", body: params
  end
end
```

**Usage:**

```ruby
client = SendfoxClient.new(token: "your_token")

# Get current user
me = client.me

# Create a new list
list = client.create_list(name: "Newsletter Subscribers")

# Add a contact
client.create_contact(
  email: "subscriber@example.com",
  first_name: "John",
  lists: [list["id"]]
)

# Find contact by email
contacts = client.contacts(email: "subscriber@example.com")
```

### Example 2: OpenAI API

```ruby
class OpenAiClient < ApplicationClient
  BASE_URI = "https://api.openai.com/v1"

  def create_completion(model:, messages:, **options)
    post "/chat/completions", body: {
      model: model,
      messages: messages,
      **options
    }
  end

  def create_image(prompt:, **options)
    post "/images/generations", body: {
      prompt: prompt,
      **options
    }
  end

  def models
    get "/models"
  end
end
```

**Usage:**

```ruby
client = OpenAiClient.new(token: "sk-...")

# Chat completion
response = client.create_completion(
  model: "gpt-4",
  messages: [
    { role: "user", content: "What is the capital of France?" }
  ]
)

puts response["choices"].first["message"]["content"]
# => "The capital of France is Paris."

# Generate image
image = client.create_image(
  prompt: "A serene mountain landscape at sunset",
  size: "1024x1024"
)

puts image["data"].first["url"]
# => "https://..."
```

### Example 3: GitHub API

```ruby
class GithubClient < ApplicationClient
  BASE_URI = "https://api.github.com"

  def user
    get "/user"
  end

  def repos
    get "/user/repos"
  end

  def repo(owner, name)
    get "/repos/#{owner}/#{name}"
  end

  def create_repo(name:, **options)
    post "/user/repos", body: {
      name: name,
      **options
    }
  end

  def create_issue(owner, repo, title:, body:)
    post "/repos/#{owner}/#{repo}/issues", body: {
      title: title,
      body: body
    }
  end
end
```

**Usage:**

```ruby
client = GithubClient.new(token: "ghp_...")

# Get authenticated user
user = client.user
puts user["login"]

# List repositories
repos = client.repos
repos.each do |repo|
  puts "#{repo['name']} - #{repo['description']}"
end

# Create a new repository
repo = client.create_repo(
  name: "my-new-project",
  description: "A cool new project",
  private: true
)

# Create an issue
issue = client.create_issue(
  user["login"],
  "my-new-project",
  title: "Bug: Something is broken",
  body: "Detailed description of the bug..."
)
```

## Advanced Usage

### Handling Pagination

```ruby
class GithubClient < ApplicationClient
  def all_repos
    repos = []
    page = 1

    loop do
      batch = get "/user/repos", params: { page: page, per_page: 100 }
      break if batch.empty?

      repos.concat(batch)
      page += 1
    end

    repos
  end
end
```

### Custom Authentication

For APIs that don't use Bearer tokens:

```ruby
class CustomAuthClient < ApplicationClient
  def initialize(api_key:, api_secret:)
    @api_key = api_key
    @api_secret = api_secret
    super()
  end

  private

  def default_options
    super.deep_merge({
      headers: {
        "X-API-Key" => @api_key,
        "X-API-Secret" => @api_secret
      }
    })
  end
end
```

### Rate Limiting

```ruby
class RateLimitedClient < ApplicationClient
  def initialize(**options)
    super
    @last_request_at = nil
    @min_request_interval = 1.0 # 1 second between requests
  end

  private

  def request(method, path, **options)
    # Wait if necessary
    if @last_request_at
      elapsed = Time.current - @last_request_at
      sleep_time = @min_request_interval - elapsed
      sleep(sleep_time) if sleep_time > 0
    end

    response = super
    @last_request_at = Time.current
    response
  end
end
```

### Response Caching

```ruby
class CachedClient < ApplicationClient
  def initialize(**options)
    super
    @cache = {}
  end

  def get(path, params: {}, cache: false, **options)
    if cache
      cache_key = "#{path}:#{params.to_json}"
      @cache[cache_key] ||= super(path, params: params, **options)
    else
      super
    end
  end
end

# Usage
client = CachedClient.new(token: "...")
users = client.get("/users", cache: true) # Cached
users = client.get("/users", cache: true) # Uses cached version
```

### File Uploads

For APIs that require file uploads:

```ruby
class FileUploadClient < ApplicationClient
  def upload_file(file_path, purpose:)
    File.open(file_path, 'rb') do |file|
      post "/files",
        body: {
          file: file,
          purpose: purpose
        },
        headers: {
          "Content-Type" => "multipart/form-data"
        }
    end
  end
end
```

### XML Parsing

For APIs that return XML instead of JSON:

```ruby
require 'nokogiri'

class XmlApiClient < ApplicationClient
  private

  def default_options
    super.deep_merge({
      headers: {
        "Content-Type" => "application/xml",
        "Accept" => "application/xml"
      },
      format: :xml
    })
  end

  def parse_response(response)
    return super unless response.success?
    Nokogiri::XML(response.body)
  end
end
```

## Best Practices

### 1. Use Environment Variables for Tokens

```ruby
# Good
client = StripeClient.new(token: ENV['STRIPE_API_KEY'])

# Bad
client = StripeClient.new(token: "sk_live_...")
```

### 2. Add Helper Methods

```ruby
class StripeClient < ApplicationClient
  # Helper method for common operation
  def create_customer_with_payment(email:, payment_method_id:)
    customer = create_customer(email: email)
    attach_payment_method(customer["id"], payment_method_id)
    customer
  end
end
```

### 3. Handle Errors Gracefully

```ruby
def safe_api_call
  begin
    client.some_api_call
  rescue StandardError => e
    Rails.logger.error "API call failed: #{e.message}"
    nil
  end
end
```

### 4. Use Background Jobs for Long-Running Operations

```ruby
class SyncDataJob < ApplicationJob
  def perform(user_id)
    user = User.find(user_id)
    client = ExternalApiClient.new(token: user.api_token)

    data = client.fetch_all_data
    user.update(synced_data: data)
  end
end

# Usage
SyncDataJob.perform_later(current_user.id)
```

### 5. Document Your API Methods

```ruby
class MyApiClient < ApplicationClient
  # Get user information
  # @param user_id [Integer] The ID of the user
  # @return [Hash] User data including name, email, and profile
  def user(user_id)
    get "/users/#{user_id}"
  end
end
```

## Troubleshooting

### Common Issues

#### 1. SSL Certificate Errors

```ruby
# Temporarily disable SSL verification (NEVER in production!)
class MyApiClient < ApplicationClient
  def default_options
    super.deep_merge({
      verify: false  # Only for development!
    })
  end
end
```

#### 2. Timeout Errors

```ruby
# Increase timeout
client = MyApiClient.new(token: "...")
client.get("/slow-endpoint", timeout: 120) # 2 minutes
```

#### 3. Rate Limiting

Handle rate limit errors:

```ruby
def handle_error(response)
  if response.code == 429
    retry_after = response.headers['Retry-After'].to_i
    sleep(retry_after)
    # Retry logic here
  else
    super
  end
end
```

## Resources

- [HTTParty Documentation](https://github.com/jnunemaker/httparty)
- [WebMock Documentation](https://github.com/bblimke/webmock)
- [GoRails Video: Net HTTP API Client from Scratch](https://gorails.com)

## Contributing

When adding new API clients to your project:

1. Use the generator: `rails g api_client YourApi`
2. Implement only the methods you need
3. Write tests for each method
4. Document the client with comments
5. Add usage examples in comments

## License

This API client infrastructure is part of the Rails SaaS Kit and follows the same license terms.
