class Accounts::InvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_invitation, only: [:destroy, :resend]

  def index
    authorize AccountInvitation
    @pending_invitations = Current.account.account_invitations.pending.order(created_at: :desc)
    @expired_invitations = Current.account.account_invitations.expired.order(created_at: :desc).limit(10)
  end

  def new
    @invitation = Current.account.account_invitations.new
    authorize @invitation
  end

  def create
    @invitation = Current.account.account_invitations.new(invitation_params)
    @invitation.invited_by = current_user
    authorize @invitation

    # Check if user is already a member
    if Current.account.users.exists?(email: @invitation.email)
      redirect_to account_invitations_path(Current.account), alert: "#{@invitation.email} is already a member of this account."
      return
    end

    if @invitation.save
      # Send invitation email
      InvitationMailer.invitation_email(@invitation).deliver_later

      redirect_to account_invitations_path(Current.account), notice: "Invitation sent to #{@invitation.email}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @invitation

    @invitation.destroy
    redirect_to account_invitations_path(Current.account), notice: "Invitation cancelled."
  end

  def resend
    authorize @invitation

    if @invitation.expired?
      # Update expiration date
      @invitation.update(expires_at: AccountInvitation::EXPIRATION_DAYS.days.from_now)
    end

    # Resend invitation email
    InvitationMailer.invitation_email(@invitation).deliver_later

    redirect_to account_invitations_path(Current.account), notice: "Invitation resent to #{@invitation.email}."
  end

  private

  def set_invitation
    @invitation = Current.account.account_invitations.find(params[:id])
  end

  def invitation_params
    params.require(:account_invitation).permit(:name, :email, :role)
  end
end
