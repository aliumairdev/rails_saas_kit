# Solid Queue configuration for Review Collector
# This file configures recurring jobs for the application

Rails.application.configure do
  # Configure recurring jobs for Solid Queue
  # These will be automatically scheduled and executed

  config.after_initialize do
    # Only configure recurring jobs in production or when explicitly enabled
    if Rails.env.production? || ENV["ENABLE_RECURRING_JOBS"] == "true"
      SolidQueue::RecurringTask.create_or_find_by!(
        key: "check_review_status_daily",
        schedule: "0 2 * * *", # Run at 2 AM every day
        class_name: "CheckReviewStatusJob"
      )

      # Schedule campaigns to run every hour
      SolidQueue::RecurringTask.create_or_find_by!(
        key: "schedule_campaigns_hourly",
        schedule: "0 * * * *", # Run every hour
        class_name: "ScheduleAllCampaignsJob"
      )

      # Check for expiring trials daily
      SolidQueue::RecurringTask.create_or_find_by!(
        key: "check_expiring_trials",
        schedule: "0 9 * * *", # Run at 9 AM every day
        class_name: "CheckExpiringTrialsJob"
      )

      Rails.logger.info "Solid Queue recurring tasks configured"
    end
  rescue StandardError => e
    # Don't fail app boot if recurring tasks can't be configured
    Rails.logger.error "Failed to configure recurring tasks: #{e.message}"
  end
end
