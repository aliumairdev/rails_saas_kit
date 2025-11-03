class NotificationPreferencesController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
    @preferences = @user.preferences["notifications"] || {}
  end

  def update
    current_user.preferences ||= {}
    current_user.preferences["notifications"] = notification_params.to_h

    if current_user.save
      redirect_to edit_notification_preferences_path, notice: "Notification preferences updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def notification_params
    params.require(:notifications).permit(
      :email,
      :in_app,
      :review_clicked,
      :request_limit,
      :payment_failed,
      :weekly_summary
    )
  end
end
