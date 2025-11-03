source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.2", ">= 8.0.2.1"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails", "~> 4.0"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

# Authentication
gem "devise", github: "excid3/devise", branch: "sign-in-after-reset-password-proc"
gem "devise-i18n", "~> 1.10"

# OAuth / Social Login
gem "omniauth", "~> 2.1"
gem "omniauth-rails_csrf_protection", "~> 1.0"
gem "omniauth-github", "~> 2.0"
gem "omniauth-google-oauth2", "~> 1.1"
gem "omniauth-facebook", "~> 10.0"
gem "omniauth-twitter2", "~> 0.1.0"

# Authorization
gem "pundit", "~> 2.1"

# Payments
gem "pay", "~> 11.0"
gem "stripe", "~> 15.0"
gem "receipts", "~> 2.1"

# Notifications
gem "noticed", "~> 2.2"

# Pagination
gem "pagy", "~> 6.0"

# Rate limiting
gem "rack-attack", "~> 6.7"

# Activity tracking
gem "paper_trail", "~> 15.0"

# CSV support for Ruby 3.4+
gem "csv", "~> 3.3"

# Security headers
gem "secure_headers", "~> 6.5"

# Spam protection
gem "invisible_captcha", "~> 2.0"

# Admin panel
gem "madmin", "~> 2.0"

# User impersonation
gem "pretender", "~> 0.4"

# Name parsing
gem "name_of_person", "~> 1.0"

# Prefixed IDs
gem "prefixed_ids", "~> 1.2"

# Two-Factor Authentication
gem "rotp", "~> 6.2"
gem "rqrcode", "~> 3.0"

# UI Components
gem "hotwire_combobox", "~> 0.3"
gem "inline_svg", "~> 1.6"
gem "local_time", "~> 3.0"

# OEmbed support
gem "ruby-oembed", "~> 0.18.0", require: "oembed"

# HTTP client for API integrations
gem "httparty", "~> 0.22.0"

# Nokogiri security update
gem "nokogiri", ">= 1.12.5"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Preview emails in browser
  gem "letter_opener"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara", ">= 3.39"
  gem "selenium-webdriver", ">= 4.20.1"

  # Test HTTP requests [https://github.com/bblimke/webmock]
  gem "webmock"
end
