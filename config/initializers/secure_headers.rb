SecureHeaders::Configuration.default do |config|
  config.x_frame_options = "SAMEORIGIN"
  config.x_content_type_options = "nosniff"
  config.x_xss_protection = "1; mode=block"
  config.x_download_options = "noopen"
  config.x_permitted_cross_domain_policies = "none"
  config.referrer_policy = %w[origin-when-cross-origin strict-origin-when-cross-origin]

  # Content Security Policy
  config.csp = {
    default_src: %w['self'],
    font_src: %w['self' data: https:],
    img_src: %w['self' data: https: blob:],
    object_src: %w['none'],
    script_src: %w['self' 'unsafe-inline' 'unsafe-eval' https://js.stripe.com https://cdn.tailwindcss.com],
    style_src: %w['self' 'unsafe-inline' https:],
    frame_src: %w['self' https://js.stripe.com],
    connect_src: %w['self' https://api.stripe.com],
    base_uri: %w['self'],
    form_action: %w['self'],
    frame_ancestors: %w['self']
  }

  # HSTS - HTTP Strict Transport Security
  config.hsts = "max-age=#{1.year.to_i}; includeSubDomains; preload"
end
