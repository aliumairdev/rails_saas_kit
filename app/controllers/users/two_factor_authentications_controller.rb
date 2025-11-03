module Users
  class TwoFactorAuthenticationsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_user

    def show
      # Show current 2FA status
    end

    def new
      # Setup 2FA
      @backup_codes = @user.enable_two_factor!
      @qr_code = RQRCode::QRCode.new(@user.otp_provisioning_uri(@user.email))
    end

    def create
      # Verify and enable 2FA
      if @user.confirm_two_factor!(params[:otp_code])
        flash[:notice] = "Two-factor authentication has been enabled successfully."
        redirect_to users_two_factor_authentication_path
      else
        flash.now[:alert] = "Invalid verification code. Please try again."
        @backup_codes = @user.otp_backup_codes.split("\n")
        @qr_code = RQRCode::QRCode.new(@user.otp_provisioning_uri(@user.email))
        render :new
      end
    end

    def destroy
      @user.disable_two_factor!
      flash[:notice] = "Two-factor authentication has been disabled."
      redirect_to users_two_factor_authentication_path
    end

    def backup_codes
      # Show backup codes
      if @user.otp_required_for_login?
        @backup_codes = @user.otp_backup_codes.split("\n")
      else
        redirect_to users_two_factor_authentication_path, alert: "Two-factor authentication is not enabled."
      end
    end

    def regenerate_backup_codes
      if @user.otp_required_for_login?
        @backup_codes = @user.generate_otp_backup_codes
        @user.save
        flash[:notice] = "New backup codes have been generated."
        render :backup_codes
      else
        redirect_to users_two_factor_authentication_path, alert: "Two-factor authentication is not enabled."
      end
    end

    private

    def set_user
      @user = current_user
    end
  end
end
