class ConnectedAccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_connected_account, only: [:destroy]

  def index
    @connected_accounts = current_user.connected_accounts.order(created_at: :desc)

    # Get list of available providers from User model
    @available_providers = User.omniauth_providers

    # Create a hash of connected providers for easy lookup
    @connected_providers = @connected_accounts.index_by(&:provider)
  end

  def destroy
    provider_name = t("oauth.#{@connected_account.provider}")

    if @connected_account.destroy
      redirect_to connected_accounts_path, notice: t("connected_accounts.destroy.success", provider: provider_name)
    else
      redirect_to connected_accounts_path, alert: t("connected_accounts.destroy.error")
    end
  end

  private

  def set_connected_account
    @connected_account = current_user.connected_accounts.find(params[:id])
  end
end
