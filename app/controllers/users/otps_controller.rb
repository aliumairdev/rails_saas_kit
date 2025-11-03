module Users
  class OtpsController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:create]
    before_action :ensure_user_in_session

    def show
      # Show OTP verification form
    end

    def create
      user = User.find(session[:otp_user_id])

      if user.verify_otp_code(params[:otp_code]) || user.verify_otp_backup_code(params[:otp_code])
        sign_in(user)
        session.delete(:otp_user_id)
        redirect_to after_sign_in_path_for(user), notice: "Signed in successfully."
      else
        flash.now[:alert] = "Invalid verification code."
        render :show
      end
    end

    private

    def ensure_user_in_session
      unless session[:otp_user_id]
        redirect_to new_user_session_path, alert: "Please sign in first."
      end
    end
  end
end
