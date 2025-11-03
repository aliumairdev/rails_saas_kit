# frozen_string_literal: true

# Configure Rack::Attack for rate limiting
class Rack::Attack
  ### Configure Cache ###

  # Use Rails cache for tracking rate limits
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  ### Throttle API Requests ###

  # Throttle API requests by API token
  # Limit: 100 requests per hour per token
  throttle("api/token", limit: 100, period: 1.hour) do |req|
    # Only throttle API requests
    if req.path.start_with?("/api/")
      # Extract token from Authorization header
      auth_header = req.get_header("HTTP_AUTHORIZATION")
      if auth_header.present?
        # Expected format: "Bearer token_here"
        match = auth_header.match(/^Bearer\s+(.+)$/i)
        # Return the token as the discriminator for throttling
        match ? match[1] : nil
      end
    end
  end

  ### Custom Throttle Response ###

  # Customize the response when rate limit is exceeded
  self.throttled_responder = lambda do |env|
    retry_after = env["rack.attack.match_data"][:period]
    now = Time.now
    match_data = env["rack.attack.match_data"]

    headers = {
      "Content-Type" => "application/json",
      "Retry-After" => retry_after.to_s,
      "X-RateLimit-Limit" => match_data[:limit].to_s,
      "X-RateLimit-Remaining" => "0",
      "X-RateLimit-Reset" => (now + retry_after).to_i.to_s
    }

    body = {
      error: "Rate limit exceeded",
      message: "Too many requests. Please try again later.",
      retry_after: retry_after
    }.to_json

    [ 429, headers, [body]]
  end

  ### Allow/Block Lists ###

  # Always allow requests from localhost in development
  safelist("allow-localhost") do |req|
    # Allow all localhost traffic in development/test
    (Rails.env.development? || Rails.env.test?) && ["127.0.0.1", "::1"].include?(req.ip)
  end

  ### Logging ###

  # Log blocked/throttled requests
  ActiveSupport::Notifications.subscribe("rack.attack") do |name, start, finish, request_id, payload|
    req = payload[:request]

    if [:throttle, :blocklist].include?(req.env["rack.attack.match_type"])
      Rails.logger.warn(
        "[Rack::Attack][#{req.env['rack.attack.match_type']}] " \
        "path=#{req.path} ip=#{req.ip} " \
        "discriminator=#{req.env['rack.attack.matched']}"
      )
    end
  end
end
