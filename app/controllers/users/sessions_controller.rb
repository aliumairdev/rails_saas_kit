module Users
  class SessionsController < Devise::SessionsController
    def create
      self.resource = warden.authenticate(auth_options)

      if resource && resource.otp_required_for_login?
        # Store user ID in session for 2FA verification
        session[:otp_user_id] = resource.id
        sign_out(resource)
        redirect_to users_otp_path
      else
        # Normal Devise behavior
        super
      end
    end
  end
end
