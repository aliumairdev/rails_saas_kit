module Api
  module V1
    class BaseController < ActionController::API
      include ApiAuthenticatable
      include Pagy::Backend

      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :render_invalid_record
      rescue_from Pundit::NotAuthorizedError, with: :render_forbidden

      private

      def render_not_found
        render json: { error: "Record not found" }, status: :not_found
      end

      def render_invalid_record(exception)
        render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
      end

      def render_forbidden
        render json: { error: "You are not authorized to perform this action" }, status: :forbidden
      end

      def pagination_meta(pagy)
        {
          current_page: pagy.page,
          total_pages: pagy.pages,
          total_count: pagy.count,
          per_page: pagy.items
        }
      end
    end
  end
end
