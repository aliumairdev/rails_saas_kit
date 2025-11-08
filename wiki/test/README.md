# Rails SaaS Kit - Test Suite

Complete test suite for the Rails SaaS Starter Kit with models, controllers, integration, and system tests.

## Test Structure

```
test/
├── application_system_test_case.rb  # System test configuration
├── test_helper.rb                    # Main test configuration
├── fixtures/                         # Test data
│   ├── users.yml
│   ├── accounts.yml
│   ├── account_users.yml
│   ├── plans.yml
│   ├── api_tokens.yml
│   ├── announcements.yml
│   └── account_invitations.yml
├── models/                          # Model tests
│   ├── user_test.rb
│   ├── account_test.rb
│   ├── plan_test.rb
│   └── api_token_test.rb
├── controllers/                     # Controller tests
│   ├── accounts_controller_test.rb
│   ├── users/
│   │   ├── sessions_controller_test.rb
│   │   ├── otp_controller_test.rb
│   │   └── two_factor_authentication_controller_test.rb
│   └── admin/
│       └── impersonations_controller_test.rb
├── integration/                     # Integration tests
│   ├── user_authentication_test.rb
│   ├── two_factor_authentication_test.rb
│   └── account_management_test.rb
├── system/                          # Browser tests
│   ├── user_registration_test.rb
│   └── two_factor_authentication_test.rb
└── support/                         # Test helpers
    ├── system/
    │   └── trix_system_test_helper.rb
    ├── stripe_helper.rb
    └── authentication_helper.rb
```

## Running Tests

### All Tests
```bash
rails test
```

### Specific Test Type
```bash
rails test:models          # Run model tests
rails test:controllers     # Run controller tests
rails test:integration     # Run integration tests
rails test:system         # Run system tests
```

### Single Test File
```bash
rails test test/models/user_test.rb
```

### Single Test
```bash
rails test test/models/user_test.rb:25  # Run test at line 25
```

### With Coverage
```bash
rails test
```

### Parallel Execution
Tests run in parallel by default (using all CPU cores)

To disable:
```bash
PARALLEL_WORKERS=1 rails test
```

## Test Configuration

### Test Helper (`test/test_helper.rb`)
- WebMock configuration (blocks external HTTP)
- Devise test helpers
- Parallel execution
- Fixtures
- JSON response helper
- Account switching helper

### System Test Helper (`test/application_system_test_case.rb`)
- Capybara/Selenium setup
- Headless Chrome driver
- Screen size: 1400x1400
- Warden helpers for authentication
- Trix editor support

### Fixtures
All fixtures use `UNIQUE_PASSWORD` for Devise compatibility and security.

Available fixtures:
- **users**: one, two, admin, with_2fa, unconfirmed
- **accounts**: personal_one, personal_two, team, admin_account
- **account_users**: Membership relationships
- **plans**: free, starter, pro, enterprise
- **api_tokens**: one, two, expired, admin_token
- **announcements**: published, unpublished, urgent
- **account_invitations**: pending, accepted, expired

## Writing Tests

### Model Test Example
```ruby
require "test_helper"

class ModelTest < ActiveSupport::TestCase
  def setup
    @model = models(:one)
  end

  test "should be valid" do
    assert @model.valid?
  end

  test "should require attribute" do
    @model.attribute = nil
    assert_not @model.valid?
  end
end
```

### Controller Test Example
```ruby
require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    sign_in @user
  end

  test "should get index" do
    get users_url
    assert_response :success
  end
end
```

### Integration Test Example
```ruby
require "test_helper"

class UserFlowTest < ActionDispatch::IntegrationTest
  test "user can sign up and log in" do
    get new_user_registration_path
    assert_response :success

    post user_registration_path, params: {
      user: {
        email: "newuser@example.com",
        password: UNIQUE_PASSWORD,
        first_name: "New",
        last_name: "User"
      }
    }

    assert_redirected_to root_path
  end
end
```

### System Test Example
```ruby
require "application_system_test_case"

class UserRegistrationTest < ApplicationSystemTestCase
  test "user can sign up" do
    visit new_user_registration_path

    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: UNIQUE_PASSWORD
    fill_in "First name", with: "Test"
    fill_in "Last name", with: "User"

    click_button "Sign up"

    assert_text "Welcome"
  end
end
```

## Mocking External Services

### Stripe (WebMock)
```ruby
stub_request(:post, "https://api.stripe.com/v1/customers")
  .to_return(status: 200, body: {id: "cus_123"}.to_json)
```

### OEmbed
```ruby
stub_request(:get, /youtube.com/)
  .to_return(status: 200, body: {html: "<iframe>...</iframe>"}.to_json)
```

## Test Helpers

### Authentication
```ruby
# In integration tests
sign_in users(:one)

# In system tests
sign_in_as users(:one)
```

### Account Switching
```ruby
switch_account accounts(:team)
```

### JSON Response
```ruby
get api_v1_users_path
data = json_response
assert_equal "John", data["first_name"]
```

## Coverage

Run tests to generate coverage report:
```bash
rails test
```

Coverage reports are in `coverage/` directory.

## Continuous Integration

Tests run automatically on:
- Push to main branch
- Pull requests
- Scheduled builds (nightly)

### GitHub Actions Workflow
See `.github/workflows/test.yml` for CI configuration.

Services:
- PostgreSQL 14
- Redis (for caching)
- Chrome (for system tests)

## Security Testing

### Brakeman (Security Scanning)
```bash
bundle exec brakeman
```

### Bundler Audit (Gem Vulnerabilities)
```bash
bundle exec bundler-audit check --update
```

### Rubocop (Code Quality)
```bash
bundle exec rubocop
```

## Troubleshooting

### Database Issues
```bash
RAILS_ENV=test rails db:reset
```

### ChromeDriver Issues
```bash
brew upgrade chromedriver  # macOS
# Or update selenium-webdriver gem
```

### Parallel Test Failures
```bash
# Run serially for debugging
PARALLEL_WORKERS=1 rails test
```

### WebMock Blocking Requests
Allowed hosts are configured in `test/test_helper.rb`:
- localhost
- chromedriver.storage.googleapis.com
- selenium

To allow additional hosts, edit WebMock configuration.

## Best Practices

1. **Use fixtures** for basic data, build objects in tests for specific scenarios
2. **Mock external services** (Stripe, OEmbed) to avoid API rate limits
3. **Test edge cases** (nil values, invalid data, expired tokens)
4. **Keep tests fast** - avoid unnecessary database calls
5. **Use descriptive test names** - test "should do something specific"
6. **Test one thing per test** - easier to debug failures
7. **Use setup/teardown** for common test data
8. **Assert meaningful messages** - `assert user.valid?, "User should be valid"`

## Test Data Guidelines

- Use `UNIQUE_PASSWORD` for all user passwords
- Use descriptive fixture names (e.g., `user_with_2fa`, not `user3`)
- Keep fixtures minimal - add specific data in tests
- Use realistic data (valid emails, proper timestamps)

## Performance

- **Parallel execution**: Tests run on all CPU cores by default
- **Transaction rollback**: Each test runs in a transaction (fast cleanup)
- **Lazy loading**: Fixtures loaded only when accessed
- **Efficient matchers**: Use built-in assertions (faster than custom)

## Additional Resources

- [Rails Testing Guide](https://guides.rubyonrails.org/testing.html)
- [Minitest Documentation](https://github.com/seattlerb/minitest)
- [Capybara Cheat Sheet](https://devhints.io/capybara)
- [WebMock Documentation](https://github.com/bblimke/webmock)
- [Devise Testing Guide](https://github.com/heartcombo/devise#test-helpers)
