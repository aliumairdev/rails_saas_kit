module Api
  module V1
    class ReviewRequestsController < BaseController
      # GET /api/v1/review_requests.json
      # Lists all review requests for the current user
      def index
        # TODO: Implement review requests listing
        # Example implementation:
        # @pagy, review_requests = pagy(current_user.review_requests.order(created_at: :desc))
        # render json: {
        #   review_requests: review_requests.map { |rr| review_request_json(rr) },
        #   meta: pagination_meta(@pagy)
        # }

        render json: {
          error: "Review requests endpoint not yet implemented",
          message: "Please implement the ReviewRequest model and this controller action"
        }, status: :not_implemented
      end

      # GET /api/v1/review_requests/:id.json
      # Shows a specific review request
      def show
        # TODO: Implement review request show
        # Example implementation:
        # review_request = current_user.review_requests.find(params[:id])
        # render json: review_request_json(review_request)

        render json: {
          error: "Review requests endpoint not yet implemented",
          message: "Please implement the ReviewRequest model and this controller action"
        }, status: :not_implemented
      end

      # POST /api/v1/review_requests.json
      # Creates a new review request
      def create
        # TODO: Implement review request creation
        # Example implementation:
        # review_request = current_user.review_requests.create!(review_request_params)
        # render json: review_request_json(review_request), status: :created

        render json: {
          error: "Review requests endpoint not yet implemented",
          message: "Please implement the ReviewRequest model and this controller action"
        }, status: :not_implemented
      end

      private

      # Example helper method for JSON serialization
      # def review_request_json(review_request)
      #   {
      #     id: review_request.id,
      #     customer_id: review_request.customer_id,
      #     status: review_request.status,
      #     sent_at: review_request.sent_at,
      #     created_at: review_request.created_at,
      #     updated_at: review_request.updated_at
      #   }
      # end

      # def review_request_params
      #   params.require(:review_request).permit(:customer_id, :message)
      # end
    end
  end
end
