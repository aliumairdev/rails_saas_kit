# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create subscription plans
puts "Creating subscription plans..."

Plan.find_or_create_by!(name: "Free") do |plan|
  plan.amount = 0 # Free
  plan.interval = "month"
  plan.interval_count = 1
  plan.currency = "usd"
  plan.description = "Perfect for trying out Review Collector"
  plan.trial_period_days = 0
  plan.hidden = false
  plan.details = {
    max_requests: 100,
    max_campaigns: 5,
    email_support: true,
    sms_notifications: false,
    priority_support: false,
    api_access: false,
    custom_integrations: false
  }
end

Plan.find_or_create_by!(name: "Starter") do |plan|
  plan.amount = 990 # $9.90 in cents
  plan.interval = "month"
  plan.interval_count = 1
  plan.currency = "usd"
  plan.description = "Perfect for small businesses getting started with review collection"
  plan.trial_period_days = 14
  plan.hidden = false
  plan.stripe_id = ENV["STRIPE_STARTER_PRICE_ID"] # Set this in your .env file
  plan.details = {
    max_requests: 1000,
    max_campaigns: 20,
    email_support: true,
    sms_notifications: true,
    priority_support: false,
    api_access: false,
    custom_integrations: false
  }
end

Plan.find_or_create_by!(name: "Pro") do |plan|
  plan.amount = 2900 # $29.00 in cents
  plan.interval = "month"
  plan.interval_count = 1
  plan.currency = "usd"
  plan.description = "For growing businesses that need more reviews and advanced features"
  plan.trial_period_days = 14
  plan.hidden = false
  plan.stripe_id = ENV["STRIPE_PRO_PRICE_ID"] # Set this in your .env file
  plan.details = {
    max_requests: 5000,
    max_campaigns: 100,
    email_support: true,
    sms_notifications: true,
    priority_support: true,
    api_access: true,
    custom_integrations: false
  }
end

Plan.find_or_create_by!(name: "Enterprise") do |plan|
  plan.amount = 9900 # $99.00 in cents
  plan.interval = "month"
  plan.interval_count = 1
  plan.currency = "usd"
  plan.description = "For enterprises that need unlimited reviews and premium support"
  plan.trial_period_days = 14
  plan.hidden = false
  plan.stripe_id = ENV["STRIPE_ENTERPRISE_PRICE_ID"] # Set this in your .env file
  plan.details = {
    max_requests: 99999,
    max_campaigns: 9999,
    email_support: true,
    sms_notifications: true,
    priority_support: true,
    api_access: true,
    custom_integrations: true,
    dedicated_account_manager: true
  }
end

puts "✓ Created #{Plan.count} subscription plans"

# Optionally create a demo admin user (only in development)
if Rails.env.development?
  puts "\nCreating demo admin user..."

  admin = User.find_or_create_by!(email: "admin@example.com") do |user|
    user.password = "password123"
    user.password_confirmation = "password123"
    user.confirmed_at = Time.current
    user.name = "Admin User"
  end

  # Create personal account for admin
  unless admin.accounts.exists?
    account = Account.create!(
      name: "#{admin.name}'s Account",
      owner: admin,
      personal: true
    )
    account.account_users.create!(user: admin)
    puts "✓ Created admin account"
  end

  puts "✓ Demo admin user created: admin@example.com / password123"
end

puts "\n✓ Seed completed successfully!"
