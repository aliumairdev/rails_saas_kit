module Api
  module V1
    class AccountsController < BaseController
      # GET /api/v1/accounts.json
      # Returns all accounts the current user has access to
      def index
        accounts = current_user.accounts.includes(:owner)

        render json: accounts.map { |account|
          {
            id: account.id,
            name: account.name,
            personal: account.personal?,
            owner_id: account.owner_id,
            created_at: account.created_at,
            updated_at: account.updated_at,
            role: current_user.account_role(account),
            is_owner: current_user.account_owner?(account),
            is_admin: current_user.account_admin?(account)
          }
        }
      end

      # GET /api/v1/accounts/:id.json
      # Returns details about a specific account
      def show
        account = current_user.accounts.find(params[:id])

        render json: {
          id: account.id,
          name: account.name,
          personal: account.personal?,
          owner_id: account.owner_id,
          created_at: account.created_at,
          updated_at: account.updated_at,
          role: current_user.account_role(account),
          is_owner: current_user.account_owner?(account),
          is_admin: current_user.account_admin?(account),
          members_count: account.account_users.count
        }
      end
    end
  end
end
