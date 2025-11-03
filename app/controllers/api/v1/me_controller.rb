module Api
  module V1
    class MeController < BaseController
      # GET /api/v1/me.json
      # Returns the currently authenticated user's information
      def show
        render json: {
          id: current_user.id,
          email: current_user.email,
          first_name: current_user.first_name,
          last_name: current_user.last_name,
          name: current_user.name,
          time_zone: current_user.time_zone,
          admin: current_user.admin?,
          created_at: current_user.created_at,
          updated_at: current_user.updated_at,
          avatar_url: current_user.avatar.attached? ? url_for(current_user.avatar) : nil
        }
      end
    end
  end
end
