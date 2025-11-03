class InvitationAcceptancesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:show]
  before_action :set_invitation

  def show
    # Show invitation details and acceptance form
    if @invitation.expired?
      @error = "This invitation has expired."
    elsif @invitation.accepted?
      @error = "This invitation has already been accepted."
    elsif user_signed_in? && current_user.accounts.include?(@invitation.account)
      @error = "You are already a member of this account."
    end
  end

  def accept
    if @invitation.expired?
      redirect_to invitation_path(token: @invitation.token), alert: "This invitation has expired."
      return
    end

    if @invitation.accepted?
      redirect_to invitation_path(token: @invitation.token), alert: "This invitation has already been accepted."
      return
    end

    if user_signed_in?
      # User is already logged in
      if @invitation.accept!(current_user)
        # Switch to the new account
        session[:account_id] = @invitation.account_id

        redirect_to dashboard_path, notice: "Welcome to #{@invitation.account.name}! You've successfully joined the team."
      else
        redirect_to invitation_path(token: @invitation.token), alert: "Unable to accept invitation. Please try again."
      end
    else
      # User needs to sign up or sign in
      # Store invitation token in session
      session[:invitation_token] = @invitation.token

      redirect_to new_user_registration_path, notice: "Please create an account or sign in to accept the invitation."
    end
  end

  private

  def set_invitation
    @invitation = AccountInvitation.find_by!(token: params[:token])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Invalid invitation link."
  end
end
