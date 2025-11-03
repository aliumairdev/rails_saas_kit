InvisibleCaptcha.setup do |config|
  # Disable timestamp and spinner checks in test environment
  config.timestamp_enabled = !Rails.env.test?
  config.spinner_enabled = !Rails.env.test?

  # Honeypot field names
  if Rails.env.test?
    config.honeypots = ["honeypotx"]
  else
    config.honeypots = [:subtitle, :website, :company_website]
  end

  # Time threshold (in seconds) for form submission
  config.timestamp_threshold = 2
end
