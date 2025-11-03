class Accounts::BillingController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account
  before_action :authorize_billing_access
  after_action :verify_authorized

  def show
    authorize @account, :billing?
    @subscription = @account.payment_processor.subscription
    @plans = Plan.visible.monthly.order(:amount)
    @current_plan = @subscription&.plan
  end

  def new
    authorize @account, :billing?
    @plans = Plan.visible.monthly.order(:amount)
    @selected_plan = Plan.find_by(id: params[:plan_id])
  end

  def create
    authorize @account, :billing?
    plan = Plan.find(params[:plan_id])

    begin
      # Create or update Stripe customer
      unless @account.payment_processor.processor_id.present?
        @account.payment_processor.create_customer(
          email: @account.billing_email || @account.owner.email,
          name: @account.name
        )
      end

      # Create checkout session with trial period
      checkout_params = {
        mode: "subscription",
        line_items: [{
          price: plan.stripe_id,
          quantity: 1
        }],
        success_url: account_billing_url(@account, checkout_success: true),
        cancel_url: new_account_billing_url(@account, plan_id: plan.id)
      }

      # Add trial period if plan has one configured
      if plan.trial_period_days > 0
        checkout_params[:subscription_data] = {
          trial_period_days: plan.trial_period_days,
          metadata: {
            account_id: @account.id,
            plan_id: plan.id
          }
        }
      end

      checkout = @account.payment_processor.checkout(**checkout_params)

      redirect_to checkout.url, allow_other_host: true
    rescue => e
      Rails.logger.error "Stripe checkout error: #{e.message}"
      redirect_to new_account_billing_path(@account, plan_id: plan.id),
                  alert: "There was an error processing your request. Please try again."
    end
  end

  private

  def set_account
    @account = current_user.accounts.find(params[:account_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to accounts_path, alert: "Account not found."
  end

  def authorize_billing_access
    unless current_user.account_owner?(@account)
      redirect_to account_path(@account), alert: "Only account owners can manage billing."
    end
  end
end
