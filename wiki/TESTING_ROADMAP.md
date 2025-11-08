# Testing Roadmap & Missing Test Coverage

This document outlines the current test coverage status and provides a roadmap for achieving comprehensive test coverage across the Rails SaaS Kit.

---

## 📊 Current Test Coverage Summary

### ✅ Well-Tested Areas (80%+ Coverage)

**Models (8/11 tested - 73%):**
- ✅ `User` (32 tests) - Authentication, 2FA, accounts, preferences
- ✅ `Account` (19 tests) - Multi-tenancy, ownership, subscriptions
- ✅ `AccountUser` (19 tests) - Roles, memberships
- ✅ `AccountInvitation` (28 tests) - Invitation flow, expiration, tokens
- ✅ `Plan` (19 tests) - Subscription plans, features, scopes
- ✅ `ApiToken` (18 tests) - Token generation, hashing, expiration
- ✅ `Announcement` (18 tests) - Publishing, dismissals, types
- ✅ `AnnouncementDismissal` (7 tests) - User dismissals

**Integration Tests (2 files):**
- ✅ `UserAuthentication` (9 tests) - Signup, login, confirmation, password reset
- ✅ `TwoFactorAuthentication` (8 tests, 2 skipped) - 2FA setup, OTP verification

**API Client Tests (2 files):**
- ✅ `OpenAiClient` - HTTP mocking with WebMock
- ✅ `SendfoxClient` - API request testing

---

## ❌ Missing Test Coverage (Priority Order)

### 🔴 **CRITICAL PRIORITY** - Core Functionality (0% Coverage)

These features are production-critical and have zero test coverage:

#### 1. **API Endpoints (6 controllers - 0 tests)**
**Risk Level: HIGH** - Public API with no automated testing

Files needing tests:
```
test/controllers/api/v1/auth_controller_test.rb          (NEW)
test/controllers/api/v1/me_controller_test.rb           (NEW)
test/controllers/api/v1/accounts_controller_test.rb      (NEW)
test/requests/api/v1/authentication_test.rb              (NEW)
test/requests/api/v1/rate_limiting_test.rb               (NEW)
test/requests/api/v1/pagination_test.rb                  (NEW)
```

**What to Test:**
- Password authentication (`POST /api/v1/auth`)
- Bearer token authentication
- Current user endpoint (`GET /api/v1/me`)
- Account endpoints (index, show, create, update)
- Rate limiting (Rack Attack integration)
- Error responses (401, 403, 404, 422, 429)
- Pagination with Pagy
- JSON response format

**Example Test Structure:**
```ruby
# test/requests/api/v1/authentication_test.rb
class Api::V1::AuthenticationTest < ActionDispatch::IntegrationTest
  test "authenticate with valid credentials returns token" do
    user = users(:one)
    post api_v1_auth_url, params: {
      email: user.email,
      password: "password"
    }, as: :json

    assert_response :success
    assert_not_nil json_response["token"]
  end

  test "authenticate with invalid credentials returns 401" do
    post api_v1_auth_url, params: {
      email: "invalid@example.com",
      password: "wrong"
    }, as: :json

    assert_response :unauthorized
  end
end
```

#### 2. **OAuth/Social Login (4 providers - 0 tests)**
**Risk Level: HIGH** - Complex authentication flow with no coverage

Files needing tests:
```
test/controllers/users/omniauth_callbacks_controller_test.rb  (NEW)
test/integration/oauth_authentication_test.rb                 (NEW)
test/models/connected_account_test.rb                         (NEW)
```

**What to Test:**
- GitHub OAuth callback handling
- Google OAuth callback handling
- Facebook OAuth callback handling
- Twitter OAuth callback handling
- Account linking to existing users
- New user creation from OAuth
- Error handling (OAuth failure, missing email)
- Connected account management (disconnect, reconnect)

**Example Test Structure:**
```ruby
# test/integration/oauth_authentication_test.rb
class OAuthAuthenticationTest < ActionDispatch::IntegrationTest
  test "sign in with GitHub creates connected account" do
    OmniAuth.config.add_mock(:github, {
      uid: "123545",
      info: { email: "github@example.com", name: "GitHub User" }
    })

    assert_difference "ConnectedAccount.count" do
      post user_github_omniauth_callback_path
    end

    assert_redirected_to root_path
    assert_equal "Successfully authenticated from Github account.", flash[:notice]
  end

  test "linking GitHub to existing user account" do
    user = users(:one)
    sign_in user

    OmniAuth.config.add_mock(:github, {
      uid: "123545",
      info: { email: user.email }
    })

    assert_difference "user.connected_accounts.count" do
      post user_github_omniauth_callback_path
    end
  end
end
```

#### 3. **Billing & Payments (2 controllers - 0 tests)**
**Risk Level: HIGH** - Financial transactions without test coverage

Files needing tests:
```
test/controllers/accounts/billing_controller_test.rb          (NEW)
test/integration/subscription_flow_test.rb                    (NEW)
test/integration/payment_webhook_test.rb                      (NEW)
```

**What to Test:**
- Subscription creation flow
- Plan upgrades and downgrades
- Payment method management
- Billing portal access
- Stripe webhook handling (payment succeeded, payment failed, subscription canceled)
- Trial expiration logic
- Invoice generation
- Receipt generation

**Example Test Structure:**
```ruby
# test/integration/subscription_flow_test.rb
class SubscriptionFlowTest < ActionDispatch::IntegrationTest
  test "user can subscribe to a plan" do
    user = users(:one)
    account = accounts(:personal)
    plan = plans(:pro)
    sign_in user

    # Mock Stripe subscription creation
    stub_request(:post, %r{https://api.stripe.com/v1/subscriptions})
      .to_return(status: 200, body: stripe_subscription_response.to_json)

    post account_billing_path(account), params: {
      plan_id: plan.id,
      payment_method_id: "pm_card_visa"
    }

    assert_redirected_to account_billing_path(account)
    assert_equal "Successfully subscribed to #{plan.name}!", flash[:notice]
    assert account.subscriptions.active.exists?
  end
end
```

---

### 🟡 **HIGH PRIORITY** - User-Facing Features (0% Coverage)

#### 4. **Account Management Controllers (5 controllers - 0 tests)**

Files needing tests:
```
test/controllers/accounts_controller_test.rb                  (PARTIAL - needs expansion)
test/controllers/account/settings_controller_test.rb          (NEW)
test/controllers/accounts/invitations_controller_test.rb      (NEW)
test/controllers/invitation_acceptances_controller_test.rb    (NEW)
test/controllers/connected_accounts_controller_test.rb        (NEW)
```

**What to Test:**
- Account creation (personal vs team)
- Account switching
- Account settings updates (name, subdomain, logo)
- Member management (add, remove, change roles)
- Invitation sending
- Invitation acceptance flow
- Connected account disconnection

#### 5. **Notifications System (2 controllers - 0 tests)**

Files needing tests:
```
test/controllers/notifications_controller_test.rb             (NEW)
test/controllers/notification_preferences_controller_test.rb  (NEW)
test/mailers/notification_mailer_test.rb                      (NEW)
```

**What to Test:**
- Notification list rendering
- Mark as read/unread
- Mark all as read
- Notification preferences updates
- Email notification delivery
- Real-time notification broadcasting (ActionCable)

#### 6. **Admin Features (2 controllers + Madmin - 0 tests)**

Files needing tests:
```
test/controllers/admin/impersonations_controller_test.rb      (NEW)
test/system/admin_impersonation_test.rb                       (NEW)
test/system/madmin_resource_management_test.rb                (NEW)
```

**What to Test:**
- Admin-only access control
- User impersonation start/stop
- Impersonation banner visibility
- Madmin resource CRUD operations
- Activity log viewing (PaperTrail)

---

### 🟢 **MEDIUM PRIORITY** - Supporting Features

#### 7. **Mailers (3 mailers - 0 tests)**

Files needing tests:
```
test/mailers/account_mailer_test.rb        (NEW)
test/mailers/invitation_mailer_test.rb     (NEW)
test/mailers/notification_mailer_test.rb   (NEW)
```

**What to Test:**
- Email content and formatting
- Correct recipient addresses
- Link generation in emails
- Email attachments (receipts)

#### 8. **Background Jobs (2 jobs - 0 tests)**

Files needing tests:
```
test/jobs/check_expiring_trials_job_test.rb   (NEW)
```

**What to Test:**
- Trial expiration detection
- Notification sending for expiring trials
- Job scheduling and execution

#### 9. **System Tests for Key User Journeys (1 file - minimal coverage)**

Files needing tests:
```
test/system/account_switching_test.rb              (NEW)
test/system/team_invitation_flow_test.rb           (NEW)
test/system/subscription_upgrade_test.rb           (NEW)
test/system/oauth_login_test.rb                    (NEW)
test/system/two_factor_setup_test.rb               (expand existing)
```

**What to Test:**
- Complete user journeys with Capybara
- Multi-step workflows
- JavaScript interactions (Stimulus controllers)
- Form validations
- Error handling

---

## 🛠 Implementation Plan

### Phase 1: Critical API Coverage (Week 1)
**Goal:** Achieve 80% API test coverage

1. Write API authentication tests (bearer token + password)
2. Write API endpoint tests for all v1 controllers
3. Add rate limiting tests
4. Add pagination tests
5. **Estimated:** 15-20 test files, ~200 assertions

### Phase 2: OAuth & Security (Week 2)
**Goal:** Cover all authentication methods

1. Write OAuth callback tests for all 4 providers
2. Add connected account management tests
3. Expand 2FA tests (fix skipped tests)
4. Add security header tests
5. **Estimated:** 8-10 test files, ~100 assertions

### Phase 3: Billing & Payments (Week 3)
**Goal:** Ensure financial features are bulletproof

1. Write subscription flow tests with Stripe mocking
2. Add webhook handler tests
3. Add payment method tests
4. Add receipt generation tests
5. **Estimated:** 10-12 test files, ~80 assertions

### Phase 4: User-Facing Features (Week 4)
**Goal:** Cover all user workflows

1. Write account management tests
2. Add notification tests (in-app + email)
3. Add admin/impersonation tests
4. Add system tests for key journeys
5. **Estimated:** 15-18 test files, ~150 assertions

### Phase 5: Polish & Coverage (Week 5)
**Goal:** Reach 90% overall coverage

1. Write mailer tests
2. Add background job tests
3. Fill remaining controller gaps
4. Add missing model tests (ConnectedAccount, Current)
5. Configure SimpleCov for coverage tracking
6. **Estimated:** 8-10 test files, ~60 assertions

---

## 📈 Coverage Goals

| Area | Current | Target | Priority |
|------|---------|--------|----------|
| **Models** | 73% | 95% | 🟢 Medium |
| **Controllers** | 4% | 80% | 🔴 Critical |
| **API Endpoints** | 0% | 90% | 🔴 Critical |
| **Integration** | 30% | 80% | 🟡 High |
| **System Tests** | 10% | 60% | 🟢 Medium |
| **Mailers** | 0% | 80% | 🟢 Medium |
| **Jobs** | 0% | 80% | 🟢 Medium |
| **Overall** | ~25% | 85% | 🔴 Critical |

---

## 🧪 Testing Best Practices for This Project

### 1. Use Fixtures for Consistency
All tests should use the comprehensive fixtures in `test/fixtures/`:
- `users.yml` - Various user states (confirmed, unconfirmed, 2FA enabled, admin)
- `accounts.yml` - Personal and team accounts
- `plans.yml` - Free, paid, and enterprise plans
- `api_tokens.yml` - Active and expired tokens

### 2. Mock External Services
- **Stripe:** Use `StripeMock` or stub API calls with WebMock
- **OAuth:** Use `OmniAuth.config.add_mock`
- **Email:** Use `ActionMailer::TestHelper`
- **HTTP APIs:** Use WebMock (already configured)

### 3. Test Authorization
Every controller test should verify:
- Unauthenticated users are redirected
- Users can only access their own resources
- Admin-only features require admin role
- Pundit policies are enforced

### 4. Test Edge Cases
- Invalid inputs (malformed emails, too-long strings)
- Expired tokens
- Deleted/disabled accounts
- Rate limiting (429 responses)
- Concurrent access issues

### 5. Use Descriptive Test Names
```ruby
# Good
test "user can update account name when owner" do

# Bad
test "update" do
```

---

## 🚀 Quick Start: Writing Your First Test

### Example: Testing ConnectedAccount Model

```ruby
# test/models/connected_account_test.rb
require "test_helper"

class ConnectedAccountTest < ActiveSupport::TestCase
  test "creates connected account from omniauth hash" do
    user = users(:one)
    auth_hash = {
      "provider" => "github",
      "uid" => "12345",
      "credentials" => { "token" => "github_token_123" },
      "info" => { "email" => user.email, "name" => "Test User" }
    }

    connected_account = ConnectedAccount.create_from_omniauth(user, auth_hash)

    assert_equal "github", connected_account.provider
    assert_equal "12345", connected_account.uid
    assert_equal user, connected_account.user
    assert_not_nil connected_account.access_token
  end

  test "validates uniqueness of provider and uid" do
    existing = connected_accounts(:github_user_one)
    duplicate = ConnectedAccount.new(
      user: users(:two),
      provider: existing.provider,
      uid: existing.uid
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:uid], "has already been taken"
  end

  test "can disconnect account" do
    connected_account = connected_accounts(:github_user_one)
    user = connected_account.user

    assert_difference "user.connected_accounts.count", -1 do
      connected_account.destroy
    end
  end
end
```

---

## 📚 Additional Resources

### Testing Tools in This Project:
- **Minitest** - Default Rails test framework
- **Capybara** - System/integration testing
- **Selenium WebDriver** - Browser automation
- **WebMock** - HTTP request stubbing
- **SimpleCov** (recommended) - Coverage reporting

### Documentation:
- [Rails Testing Guide](https://guides.rubyonrails.org/testing.html)
- [Minitest Documentation](https://docs.seattlerb.org/minitest/)
- [Capybara Documentation](https://github.com/teamcapybara/capybara)
- [WebMock GitHub](https://github.com/bblimke/webmock)

### Running Tests:
```bash
# All tests
bin/rails test

# Specific file
bin/rails test test/models/user_test.rb

# Specific test
bin/rails test test/models/user_test.rb:42

# System tests
bin/rails test:system

# With coverage (after SimpleCov setup)
COVERAGE=true bin/rails test
```

---

## 🎯 Success Metrics

### Definition of Done for Testing:
- [ ] All API endpoints have request tests
- [ ] All controllers have basic CRUD tests
- [ ] All models have validation and association tests
- [ ] OAuth flows are integration tested
- [ ] Payment flows are integration tested
- [ ] Key user journeys have system tests
- [ ] SimpleCov shows 85%+ coverage
- [ ] CI pipeline runs tests on every PR
- [ ] No skipped tests remain

---

**Last Updated:** November 7, 2025
**Maintained By:** Rails SaaS Kit Contributors
