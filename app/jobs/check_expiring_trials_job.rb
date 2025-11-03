class CheckExpiringTrialsJob < ApplicationJob
  queue_as :low_priority

  def perform
    # Find accounts with trials expiring in 3 days
    Account.unscoped.find_each do |account|
      next unless account.on_trial?

      days_remaining = account.trial_days_remaining

      # Send reminder when 3 days left
      if days_remaining == 3
        AccountMailer.subscription_expiring(account).deliver_later
        Rails.logger.info "Sent trial expiring email to account #{account.id}"
      end
    rescue StandardError => e
      Rails.logger.error "Error checking trial for account #{account.id}: #{e.message}"
    end
  end
end
