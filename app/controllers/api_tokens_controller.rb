class ApiTokensController < ApplicationController
  before_action :authenticate_user!
  before_action :set_api_token, only: [:destroy]
  before_action :check_api_access

  def index
    @api_tokens = current_user.api_tokens.order(created_at: :desc)
  end

  def new
    @api_token = current_user.api_tokens.new
  end

  def create
    @api_token = current_user.api_tokens.new(api_token_params)

    if @api_token.save
      # Store the plain token in flash to show once
      flash[:api_token] = @api_token.plain_token
      redirect_to api_tokens_path, notice: "API token created successfully. Make sure to copy it now - you won't be able to see it again!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @api_token.destroy
    redirect_to api_tokens_path, notice: "API token revoked successfully."
  end

  private

  def set_api_token
    @api_token = current_user.api_tokens.find(params[:id])
  end

  def api_token_params
    params.require(:api_token).permit(:name, :expires_at)
  end

  def check_api_access
    return if Current.account.blank?

    unless Current.account.pro_plan?
      redirect_to dashboard_path, alert: "API access is only available on the Pro plan. Please upgrade to access API tokens."
    end
  end
end
