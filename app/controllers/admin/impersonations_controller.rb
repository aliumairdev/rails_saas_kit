module Admin
  class ImpersonationsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin

    def create
      user = User.find(params[:user_id])
      impersonate_user(user)
      redirect_to root_path, notice: "You are now impersonating #{user.name}."
    end

    def destroy
      stop_impersonating_user
      redirect_to madmin_users_path, notice: "Stopped impersonating user."
    end

    private

    def require_admin
      unless current_user&.admin?
        redirect_to root_path, alert: "You are not authorized to perform this action."
      end
    end
  end
end
