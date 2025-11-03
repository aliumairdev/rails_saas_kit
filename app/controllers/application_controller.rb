class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  include Pundit::Authorization
  include Pagy::Backend

  # Pretender for impersonation
  impersonates :user

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_current_user
  before_action :set_current_account, if: :user_signed_in?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :time_zone])
  end

  def set_current_user
    Current.user = current_user if user_signed_in?
  end

  def set_current_account
    if session[:account_id].present?
      account = current_user.accounts.find_by(id: session[:account_id])
      Current.account = account if account
    end

    # Default to personal account if no account is set
    Current.account ||= current_user.personal_account

    # Redirect to account selection if user has no accounts
    if Current.account.nil? && !devise_controller? && controller_name != "accounts"
      redirect_to new_account_path, alert: "Please create an account to continue."
    end
  end

  def switch_account(account)
    if current_user.accounts.include?(account)
      session[:account_id] = account.id
      Current.account = account
    end
  end

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
end
