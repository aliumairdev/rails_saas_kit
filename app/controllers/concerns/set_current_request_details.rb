module SetCurrentRequestDetails
  extend ActiveSupport::Concern

  included do
    before_action :set_request_details
  end

  private

  def set_request_details
    Current.user = current_user if respond_to?(:current_user)
    Current.account = current_account if respond_to?(:current_account)
  end

  def current_account
    @current_account ||= Current.account
  end
end
