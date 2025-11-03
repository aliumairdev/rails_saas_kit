class AccountMailer < ApplicationMailer
  def welcome_email(account)
    @account = account
    @user = account.owner

    mail(
      to: @user.email,
      subject: "Welcome to Review Collector!"
    )
  end

  def subscription_expiring(account)
    @account = account
    @user = account.owner
    @subscription = account.subscription
    @days_remaining = account.trial_days_remaining

    mail(
      to: @user.email,
      subject: "Your trial is ending soon"
    )
  end

  def request_limit_reached(account)
    @account = account
    @user = account.owner
    @plan = account.subscription_plan
    @current_usage = account.current_month_requests_count

    mail(
      to: @user.email,
      subject: "You've reached your review request limit"
    )
  end
end
