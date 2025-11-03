class AnnouncementDismissalsController < ApplicationController
  before_action :authenticate_user!

  def create
    announcement = Announcement.find(params[:announcement_id])
    dismissal = current_user.announcement_dismissals.find_or_create_by(announcement: announcement)

    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, notice: "Announcement dismissed." }
      format.turbo_stream
      format.json { head :ok }
    end
  end
end
