# API Documentation

Rails SaaS Kit provides a comprehensive RESTful API for integrating your application with external services, mobile apps, and third-party tools.

## Table of Contents

- [Overview](#overview)
- [Authentication](#authentication)
- [API Tokens](#api-tokens)
- [Rate Limiting](#rate-limiting)
- [Response Format](#response-format)
- [Error Handling](#error-handling)
- [Endpoints](#endpoints)
  - [Authentication](#post-apiv1authjson)
  - [Current User](#get-apiv1mejson)
  - [Accounts](#accounts-endpoints)
- [Pagination](#pagination)
- [Examples](#examples)

## Overview

**Base URL**: `https://your-domain.com/api/v1`

**Content Type**: `application/json`

**Authentication**: Bearer token in Authorization header

All API requests must be made over HTTPS. Requests made over HTTP will fail.

## Authentication

### Bearer Token Authentication

The primary authentication method is using API tokens with the Bearer authentication scheme.

**Header Format**:
```
Authorization: Bearer token_abc123...
```

**Example cURL Request**:
```bash
curl https://your-domain.com/api/v1/me.json \
  -H "Authorization: Bearer token_abc123..." \
  -H "Content-Type: application/json"
```

### Password Authentication

You can also authenticate using email and password to obtain an API token. This is useful for mobile apps or when you need to programmatically generate tokens.

**Endpoint**: `POST /api/v1/auth.json`

**Request Body**:
```json
{
  "email": "user@example.com",
  "password": "yourpassword"
}
```

**Success Response** (201 Created):
```json
{
  "token": "token_abc123...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

**Error Response** (401 Unauthorized):
```json
{
  "error": "Invalid email or password"
}
```

**Important Notes**:
- Email must be confirmed before API access is granted
- This endpoint does NOT require an Authorization header
- The returned token can be used for subsequent API requests

## API Tokens

### Managing API Tokens

Users can create and manage their API tokens through the web interface at `/api_tokens`.

**Features**:
- ✅ Multiple tokens per user
- ✅ Descriptive names for tokens
- ✅ Optional expiration dates
- ✅ Last used timestamp tracking
- ✅ Secure SHA256 hashing
- ✅ One-time display of plain token

### Creating an API Token (Web UI)

1. Navigate to `/api_tokens` in your web browser
2. Click "New API Token"
3. Enter a descriptive name (e.g., "Mobile App", "External Integration")
4. Optionally set an expiration date
5. Click "Create API Token"
6. **Important**: Copy the token immediately - it won't be shown again!

### Token Security

- Tokens are stored using SHA256 hashing
- Plain tokens are only shown once after creation
- Tokens can be revoked at any time
- Expired tokens are automatically rejected
- Last used timestamp helps identify inactive tokens

## Rate Limiting

The API uses Rack::Attack for rate limiting. Default limits:

- **100 requests per minute** per IP address
- **1000 requests per hour** per API token

Rate limit headers are included in all responses:
- `X-RateLimit-Limit`: Maximum requests allowed
- `X-RateLimit-Remaining`: Requests remaining in current window
- `X-RateLimit-Reset`: Time when the rate limit resets (Unix timestamp)

When rate limited, you'll receive a `429 Too Many Requests` response:

```json
{
  "error": "Rate limit exceeded",
  "retry_after": 60
}
```

## Response Format

### Success Responses

All successful responses return JSON with appropriate HTTP status codes:

- `200 OK` - Successful GET, PUT, PATCH, DELETE
- `201 Created` - Successful POST creating a resource
- `204 No Content` - Successful DELETE with no response body

### Error Responses

Error responses follow a consistent format:

```json
{
  "error": "Error message describing what went wrong"
}
```

Common HTTP status codes:

- `400 Bad Request` - Invalid request parameters
- `401 Unauthorized` - Missing or invalid authentication token
- `403 Forbidden` - Authenticated but not authorized for this action
- `404 Not Found` - Resource not found
- `422 Unprocessable Entity` - Validation errors
- `429 Too Many Requests` - Rate limit exceeded
- `500 Internal Server Error` - Server error
- `501 Not Implemented` - Endpoint exists but not yet implemented

### Validation Errors (422)

Validation errors include detailed field-level errors:

```json
{
  "error": "Validation failed",
  "errors": {
    "email": ["can't be blank", "is invalid"],
    "password": ["is too short (minimum is 6 characters)"]
  }
}
```

## Endpoints

### POST /api/v1/auth.json

Authenticate with email and password to receive an API token.

**Authentication**: Not required

**Request Body**:
```json
{
  "email": "user@example.com",
  "password": "yourpassword"
}
```

**Success Response** (201):
```json
{
  "token": "token_abc123...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

**Error Responses**:
- `401` - Invalid credentials or unconfirmed email

---

### GET /api/v1/me.json

Get information about the currently authenticated user.

**Authentication**: Required

**Request**:
```bash
curl https://your-domain.com/api/v1/me.json \
  -H "Authorization: Bearer token_abc123..."
```

**Success Response** (200):
```json
{
  "id": 1,
  "email": "user@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "name": "John Doe",
  "time_zone": "America/New_York",
  "admin": false,
  "created_at": "2025-01-15T10:30:00Z",
  "updated_at": "2025-01-20T14:45:00Z",
  "avatar_url": "https://your-domain.com/rails/active_storage/blobs/..."
}
```

**Error Responses**:
- `401` - Invalid or missing token

---

### Accounts Endpoints

#### GET /api/v1/accounts.json

List all accounts the current user has access to.

**Authentication**: Required

**Request**:
```bash
curl https://your-domain.com/api/v1/accounts.json \
  -H "Authorization: Bearer token_abc123..."
```

**Success Response** (200):
```json
[
  {
    "id": 1,
    "name": "John Doe",
    "personal": true,
    "owner_id": 1,
    "created_at": "2025-01-15T10:30:00Z",
    "updated_at": "2025-01-15T10:30:00Z",
    "role": "owner",
    "is_owner": true,
    "is_admin": true
  },
  {
    "id": 2,
    "name": "Acme Corporation",
    "personal": false,
    "owner_id": 5,
    "created_at": "2025-01-20T09:15:00Z",
    "updated_at": "2025-01-22T11:20:00Z",
    "role": "member",
    "is_owner": false,
    "is_admin": false
  }
]
```

---

#### GET /api/v1/accounts/:id.json

Get details about a specific account.

**Authentication**: Required

**Request**:
```bash
curl https://your-domain.com/api/v1/accounts/1.json \
  -H "Authorization: Bearer token_abc123..."
```

**Success Response** (200):
```json
{
  "id": 1,
  "name": "John Doe",
  "personal": true,
  "owner_id": 1,
  "created_at": "2025-01-15T10:30:00Z",
  "updated_at": "2025-01-15T10:30:00Z",
  "role": "owner",
  "is_owner": true,
  "is_admin": true,
  "members_count": 1
}
```

**Error Responses**:
- `404` - Account not found or user doesn't have access

---

### Application-Specific Endpoints

The following endpoints are placeholders for your application-specific resources. You'll need to implement the corresponding models and controller logic.

#### Campaigns

- `GET /api/v1/campaigns.json` - List campaigns
- `GET /api/v1/campaigns/:id.json` - Show campaign
- `POST /api/v1/campaigns.json` - Create campaign

#### Customers

- `GET /api/v1/customers.json` - List customers
- `GET /api/v1/customers/:id.json` - Show customer
- `POST /api/v1/customers.json` - Create customer

#### Review Requests

- `GET /api/v1/review_requests.json` - List review requests
- `GET /api/v1/review_requests/:id.json` - Show review request
- `POST /api/v1/review_requests.json` - Create review request

**Note**: These endpoints currently return `501 Not Implemented`. See the controller files for implementation examples.

## Pagination

List endpoints support pagination using the Pagy gem. Pagination metadata is included in the response under the `meta` key.

**Query Parameters**:
- `page` - Page number (default: 1)
- `items` - Items per page (default: 25, max: 100)

**Example Request**:
```bash
curl "https://your-domain.com/api/v1/accounts.json?page=2&items=50" \
  -H "Authorization: Bearer token_abc123..."
```

**Response with Pagination**:
```json
{
  "accounts": [...],
  "meta": {
    "page": 2,
    "items": 50,
    "count": 150,
    "pages": 3,
    "prev": 1,
    "next": 3,
    "from": 51,
    "to": 100
  }
}
```

## Examples

### Complete Authentication Flow

#### 1. Get API Token
```bash
curl -X POST https://your-domain.com/api/v1/auth.json \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "yourpassword"
  }'
```

Response:
```json
{
  "token": "token_abc123...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

#### 2. Use Token to Access Protected Endpoints
```bash
TOKEN="token_abc123..."

curl https://your-domain.com/api/v1/me.json \
  -H "Authorization: Bearer $TOKEN"
```

#### 3. List User's Accounts
```bash
curl https://your-domain.com/api/v1/accounts.json \
  -H "Authorization: Bearer $TOKEN"
```

### Ruby Example

```ruby
require 'net/http'
require 'json'

# Authenticate
uri = URI('https://your-domain.com/api/v1/auth.json')
request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
request.body = {
  email: 'user@example.com',
  password: 'yourpassword'
}.to_json

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end

auth_data = JSON.parse(response.body)
token = auth_data['token']

# Use token to access API
uri = URI('https://your-domain.com/api/v1/me.json')
request = Net::HTTP::Get.new(uri)
request['Authorization'] = "Bearer #{token}"

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end

user_data = JSON.parse(response.body)
puts "User: #{user_data['name']}"
```

### JavaScript/Node.js Example

```javascript
// Authenticate
const authResponse = await fetch('https://your-domain.com/api/v1/auth.json', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    email: 'user@example.com',
    password: 'yourpassword'
  })
});

const { token } = await authResponse.json();

// Use token to access API
const userResponse = await fetch('https://your-domain.com/api/v1/me.json', {
  headers: {
    'Authorization': `Bearer ${token}`
  }
});

const userData = await userResponse.json();
console.log('User:', userData.name);
```

### Python Example

```python
import requests

# Authenticate
auth_response = requests.post(
    'https://your-domain.com/api/v1/auth.json',
    json={
        'email': 'user@example.com',
        'password': 'yourpassword'
    }
)

token = auth_response.json()['token']

# Use token to access API
headers = {'Authorization': f'Bearer {token}'}

user_response = requests.get(
    'https://your-domain.com/api/v1/me.json',
    headers=headers
)

user_data = user_response.json()
print(f"User: {user_data['name']}")
```

## Implementation Guide

### Adding New API Endpoints

1. **Create Controller**: Add a new controller in `app/controllers/api/v1/`

```ruby
module Api
  module V1
    class WidgetsController < BaseController
      def index
        @pagy, widgets = pagy(current_user.widgets)
        render json: {
          widgets: widgets.map { |w| widget_json(w) },
          meta: pagination_meta(@pagy)
        }
      end

      private

      def widget_json(widget)
        {
          id: widget.id,
          name: widget.name,
          created_at: widget.created_at
        }
      end
    end
  end
end
```

2. **Add Routes**: Update `config/routes.rb`

```ruby
namespace :api do
  namespace :v1 do
    resources :widgets, only: [:index, :show, :create, :update, :destroy]
  end
end
```

3. **Add Authorization**: Use Pundit for authorization

```ruby
def show
  widget = current_user.widgets.find(params[:id])
  authorize widget  # Uses Pundit policy
  render json: widget_json(widget)
end
```

### Using JBuilder (Optional)

While the current implementation uses direct JSON rendering, you can use JBuilder for more complex responses:

1. **Create View**: `app/views/api/v1/widgets/show.json.jbuilder`

```ruby
json.id @widget.id
json.name @widget.name
json.created_at @widget.created_at
json.owner do
  json.id @widget.user.id
  json.name @widget.user.name
end
```

2. **Update Controller**:

```ruby
def show
  @widget = current_user.widgets.find(params[:id])
  # Renders app/views/api/v1/widgets/show.json.jbuilder
end
```

## Security Best Practices

1. **Always use HTTPS** in production
2. **Rotate tokens regularly** - set expiration dates
3. **Use separate tokens** for different integrations
4. **Revoke unused tokens** - check "last used" timestamp
5. **Don't commit tokens** to version control
6. **Monitor API usage** - check for unusual patterns
7. **Implement IP whitelisting** for sensitive operations
8. **Use short expiration times** for mobile apps

## Troubleshooting

### 401 Unauthorized Error

- Verify the token is included in the Authorization header
- Check that the token hasn't expired
- Ensure the token format is: `Bearer token_value`
- Confirm the user's email is confirmed

### 403 Forbidden Error

- User is authenticated but doesn't have permission
- Check Pundit policies for the resource
- Verify user has access to the account/resource

### 404 Not Found Error

- Resource doesn't exist
- User doesn't have access to the resource
- Check that the resource ID is correct

### 422 Unprocessable Entity

- Validation errors in request body
- Check the `errors` field in the response for details
- Verify all required fields are included

### 501 Not Implemented

- Endpoint exists but implementation is pending
- See the controller file for implementation examples
- Implement the corresponding model and controller logic

## Support

For issues or questions about the API:

1. Check this documentation
2. Review controller implementation in `app/controllers/api/v1/`
3. Check test files in `test/controllers/api/v1/`
4. Open an issue on GitHub

## Changelog

### Version 1.0.0 (2025-11-03)

- Initial API implementation
- Authentication with Bearer tokens
- Password-based authentication endpoint
- User information endpoint
- Accounts listing and details
- Pagination support
- Error handling
- Rate limiting

## License

This API is part of the Rails SaaS Kit and follows the same license terms.
