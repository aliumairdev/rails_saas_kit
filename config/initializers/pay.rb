Pay.setup do |config|
  # Configure the default payment processor
  config.default_product_name = "Review Collector"
  config.default_plan_name = "Review Collector Subscription"

  # Business details
  config.business_name = "Review Collector"
  config.business_address = "123 Business St"
  config.support_email = "support@reviewcollector.com"

  # Application fee (optional)
  # config.application_fee_percent = 0.5

  # Automount routes for webhooks
  config.automount_routes = true
  config.routes_path = "/pay"

  # Configure enabled payment processors
  # config.enabled_processors = [:stripe]
end
