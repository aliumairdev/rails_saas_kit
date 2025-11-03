class InvitationMailer < ApplicationMailer
  def invitation_email(invitation)
    @invitation = invitation
    @inviter = invitation.invited_by
    @account = invitation.account
    @accept_url = invitation_url(token: invitation.token)

    mail(
      to: invitation.email,
      subject: "#{@inviter.full_name} invited you to join #{@account.name} on Review Collector"
    )
  end
end
