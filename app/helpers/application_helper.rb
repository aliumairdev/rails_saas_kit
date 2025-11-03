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
end
