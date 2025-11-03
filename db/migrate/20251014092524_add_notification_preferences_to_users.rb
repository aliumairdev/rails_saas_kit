class AddNotificationPreferencesToUsers < ActiveRecord::Migration[8.0]
  def change
    # Users table already has a preferences jsonb column from devise setup
    # We'll use that for notification preferences
    # No migration needed, just documenting the structure

    # preferences structure:
    # {
    #   notifications: {
    #     email: true,
    #     in_app: true,
    #     review_clicked: true,
    #     request_limit: true,
    #     payment_failed: true,
    #     weekly_summary: true
    #   }
    # }
  end
end
