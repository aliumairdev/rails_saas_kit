class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      # Check if there's a pending invitation
      if session[:invitation_token].present?
        invitation = AccountInvitation.find_by(token: session[:invitation_token])

        if invitation && invitation.pending?
          # Accept the invitation
          invitation.accept!(resource)

          # Switch to the invited account
          session[:account_id] = invitation.account_id

          # Clear invitation token from session
          session.delete(:invitation_token)
        end
      end
    end
  end
end
