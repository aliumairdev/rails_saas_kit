class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    notifications_scope = current_user.notifications
      .includes(:event)
      .order(created_at: :desc)

    @pagy, @notifications = pagy(notifications_scope, items: 20)
    @unread_count = current_user.notifications.unread.count
  end

  def mark_as_read
    notification = current_user.notifications.find(params[:id])
    notification.mark_as_read!

    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path) }
      format.json { head :ok }
    end
  end

  def mark_all_as_read
    current_user.notifications.unread.each(&:mark_as_read!)

    respond_to do |format|
      format.html { redirect_to notifications_path, notice: "All notifications marked as read" }
      format.json { head :ok }
    end
  end
end
