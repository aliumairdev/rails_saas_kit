class Account::SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account
  before_action :authorize_account_access
  after_action :verify_authorized

  def index
    authorize @account, :update?
    redirect_to account_settings_general_path(@account)
  end

  def general
    authorize @account, :update?
  end

  def members
    authorize @account, :manage_members?
    @account_users = @account.account_users.includes(:user)
  end

  def billing
    authorize @account, :billing?
  end

  private

  def set_account
    @account = current_user.accounts.find(params[:account_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to accounts_path, alert: "Account not found."
  end

  def authorize_account_access
    unless current_user.account_member?(@account)
      redirect_to accounts_path, alert: "You don't have access to this account."
    end
  end
end
