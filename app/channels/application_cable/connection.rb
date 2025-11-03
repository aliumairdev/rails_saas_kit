module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user, :current_account

    delegate :params, :session, to: :request

    def connect
      self.current_user = find_verified_user
      set_request_details
      self.current_account = Current.account

      logger.add_tags "ActionCable", "User #{current_user.id}", "Account #{current_account.id}"
    end

    protected

    def find_verified_user
      if (verified_user = env["warden"].user(:user))
        verified_user
      else
        reject_unauthorized_connection
      end
    end

    def user_signed_in?
      !!current_user
    end

    def set_request_details
      Current.user = current_user
      Current.account = current_account
    end
  end
end
