module ApplicationHelper
  include Pagy::Frontend

  # Authorization helper for views
  def can?(action, record)
    return false unless user_signed_in?
    policy(record).public_send("#{action}?")
  rescue Pundit::NotDefinedError
    false
  end

  # Check if current user has specific role in current account
  def current_account_role
    return nil unless user_signed_in? && Current.account
    current_user.account_role(Current.account)
  end

  def current_account_owner?
    return false unless user_signed_in? && Current.account
    current_user.account_owner?(Current.account)
  end

  def current_account_admin?
    return false unless user_signed_in? && Current.account
    current_user.account_admin?(Current.account)
  end

  def current_account_member?
    return false unless user_signed_in? && Current.account
    current_user.account_member?(Current.account)
  end

  # Render toast notifications from flash messages
  def render_toast_notifications
    return unless flash[:notice] || flash[:alert] || flash[:toast]

    toasts = []

    # Handle simple string notices/alerts
    if flash[:notice].is_a?(String)
      toasts << { title: "Notice", description: flash[:notice], icon_name: :notice }
    elsif flash[:notice].is_a?(Hash)
      toasts << flash[:notice].symbolize_keys
    end

    if flash[:alert].is_a?(String)
      toasts << { title: "Alert", description: flash[:alert], icon_name: :alert }
    elsif flash[:alert].is_a?(Hash)
      toasts << flash[:alert].symbolize_keys
    end

    # Handle custom toast flash
    if flash[:toast].is_a?(Hash)
      toasts << flash[:toast].symbolize_keys
    elsif flash[:toast].is_a?(Array)
      toasts.concat(flash[:toast].map(&:symbolize_keys))
    end

    safe_join(toasts.map { |toast_data| render("shared/toast", **toast_data) })
  end
end
