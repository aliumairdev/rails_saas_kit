module Subscriptionable
  extend ActiveSupport::Concern

  included do
    # Track usage metrics
    def current_month_requests_count
      # This will need to be implemented when we have review requests model
      0
    end

    def current_campaigns_count
      # This will need to be implemented when we have campaigns model
      0
    end
  end

  # Check if account can create more requests
  def within_request_limit?
    return true unless subscribed?

    plan = subscription_plan
    return true unless plan

    # Unlimited plans always pass
    return true if plan.unlimited_requests?

    # Check current usage against limit
    current_month_requests_count < plan.max_requests
  end

  # Check if account can create more campaigns
  def can_create_campaign?
    return true unless subscribed?

    plan = subscription_plan
    return true unless plan

    # Unlimited plans always pass
    return true if plan.unlimited_campaigns?

    # Check current usage against limit
    current_campaigns_count < plan.max_campaigns
  end

  # Get percentage of requests used
  def requests_usage_percentage
    return 0 unless subscribed?

    plan = subscription_plan
    return 0 unless plan
    return 0 if plan.unlimited_requests?

    percentage = ((current_month_requests_count.to_f / plan.max_requests) * 100).round(2)

    # Send notification at 80% and 100%
    if percentage >= 80 && percentage < 100
      check_and_send_limit_notification(percentage)
    elsif percentage >= 100
      check_and_send_limit_notification(percentage)
    end

    percentage
  end

  def check_and_send_limit_notification(percentage)
    # Only send once per threshold
    threshold = percentage >= 100 ? 100 : 80
    key = "limit_notification_#{threshold}"

    # Check if notification already sent today
    last_sent = self.class.where(id: id)
      .joins("LEFT JOIN noticed_events ON noticed_events.params->>'account_id' = accounts.id::text")
      .where("noticed_events.type = 'RequestLimitReachedNotification'")
      .where("noticed_events.created_at > ?", 1.day.ago)
      .where("noticed_events.params->>'usage_percentage' = ?", threshold.to_s)
      .exists?

    unless last_sent
      RequestLimitReachedNotification.with(
        account: self,
        usage_percentage: threshold
      ).deliver(owner)
    end
  end

  # Get percentage of campaigns used
  def campaigns_usage_percentage
    return 0 unless subscribed?

    plan = subscription_plan
    return 0 unless plan
    return 0 if plan.unlimited_campaigns?

    ((current_campaigns_count.to_f / plan.max_campaigns) * 100).round(2)
  end

  # Check if a specific feature is enabled
  def has_feature?(feature_name)
    return false unless subscribed?

    plan = subscription_plan
    return false unless plan

    plan.feature(feature_name).present?
  end

  # Get current subscription plan
  def subscription_plan
    return nil unless subscribed?

    sub = subscription
    return nil unless sub&.active?

    # If plan has a processor_plan, try to match it with our Plan model
    # For now, we'll need to enhance this when we sync with Stripe
    Plan.find_by(stripe_id: sub.processor_plan) if sub.processor_plan.present?
  end

  # Human-readable subscription status
  def subscription_status_text
    return "No subscription" unless payment_processor.customer?

    if on_trial?
      "Trial (#{trial_days_remaining} days remaining)"
    elsif subscribed?
      "Active"
    else
      "Inactive"
    end
  end

  # Calculate trial days remaining
  def trial_days_remaining
    return 0 unless on_trial?

    sub = subscription
    return 0 unless sub&.trial_ends_at

    ((sub.trial_ends_at.to_date - Date.current).to_i).clamp(0, Float::INFINITY)
  end

  # Check if account needs to upgrade
  def needs_upgrade?
    !subscribed? || (!on_trial? && subscription&.canceled?)
  end
end
