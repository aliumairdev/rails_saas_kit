ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"
require "webmock/minitest"

# Uncomment to view full stack trace in tests
# Rails.backtrace_cleaner.remove_silencers!

if defined?(SolidQueue)
  SolidQueue.logger.level = Logger::WARN
end

# Generate a random password so Chrome doesn't warn about passwords in data breaches
UNIQUE_PASSWORD = Devise.friendly_token

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    def json_response
      JSON.parse(response.body)
    end

    # Helper to sign in a user
    def sign_in(user)
      post user_session_url, params: {
        user: {
          email: user.email,
          password: UNIQUE_PASSWORD
        }
      }
    end
  end
end

module ActionDispatch
  class IntegrationTest
    include Devise::Test::IntegrationHelpers

    def switch_account(account)
      patch "/accounts/#{account.id}/switch"
    end

    # Helper to sign in via HTTP POST (for integration tests)
    def sign_in_with_account(user, account: nil)
      post user_session_path, params: {
        user: {
          email: user.email,
          password: UNIQUE_PASSWORD
        }
      }
      follow_redirect! if response.redirect?

      # Set account if provided or use personal account
      account ||= user.personal_account || user.accounts.first
      if account
        patch "/accounts/#{account.id}/switch"
        follow_redirect! if response.redirect?
      end
    end

    # Helper to create a valid user password
    def user_password
      UNIQUE_PASSWORD
    end
  end
end

# Configure WebMock
WebMock.disable_net_connect!({
  allow_localhost: true,
  allow: [
    "chromedriver.storage.googleapis.com",
    "rails-app",
    "selenium"
  ]
})
