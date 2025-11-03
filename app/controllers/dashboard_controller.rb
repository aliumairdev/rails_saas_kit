class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    return redirect_to new_account_path, alert: "Please create an account first" unless Current.account


    # Quick stats for subscription
    if Current.account.subscribed?
      @usage_stats = {
        requests_used: current_month_requests_count,
        requests_limit: Current.account.subscription_plan&.max_requests || 0,
        usage_percentage: Current.account.requests_usage_percentage
      }
    end
  end

  private

  def current_month_requests_count
    ReviewRequest.where("created_at >= ?", Time.current.beginning_of_month).count
  end

  def calculate_response_rate
    total = ReviewRequest.count
    return 0 if total.zero?

    reviewed = ReviewRequest.status_reviewed.count
    ((reviewed.to_f / total) * 100).round(1)
  end

  def requests_over_time_data
    # Last 30 days
    data = (0..29).map do |days_ago|
      date = days_ago.days.ago.to_date
      count = ReviewRequest.where("DATE(created_at) = ?", date).count
      { date: date.strftime("%b %d"), count: count }
    end.reverse

    data
  end

  def response_by_campaign_data
    Campaign.includes(:review_requests).limit(5).map do |campaign|
      {
        name: campaign.name,
        response_rate: campaign.response_rate
      }
    end
  end
end
