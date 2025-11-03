module Api
  module V1
    class CustomersController < BaseController
      # GET /api/v1/customers.json
      # Lists all customers for the current user
      def index
        # TODO: Implement customers listing
        # Example implementation:
        # @pagy, customers = pagy(current_user.customers.order(created_at: :desc))
        # render json: {
        #   customers: customers.map { |customer| customer_json(customer) },
        #   meta: pagination_meta(@pagy)
        # }

        render json: {
          error: "Customers endpoint not yet implemented",
          message: "Please implement the Customer model and this controller action"
        }, status: :not_implemented
      end

      # GET /api/v1/customers/:id.json
      # Shows a specific customer
      def show
        # TODO: Implement customer show
        # Example implementation:
        # customer = current_user.customers.find(params[:id])
        # render json: customer_json(customer)

        render json: {
          error: "Customers endpoint not yet implemented",
          message: "Please implement the Customer model and this controller action"
        }, status: :not_implemented
      end

      # POST /api/v1/customers.json
      # Creates a new customer
      def create
        # TODO: Implement customer creation
        # Example implementation:
        # customer = current_user.customers.create!(customer_params)
        # render json: customer_json(customer), status: :created

        render json: {
          error: "Customers endpoint not yet implemented",
          message: "Please implement the Customer model and this controller action"
        }, status: :not_implemented
      end

      private

      # Example helper method for JSON serialization
      # def customer_json(customer)
      #   {
      #     id: customer.id,
      #     email: customer.email,
      #     name: customer.name,
      #     created_at: customer.created_at,
      #     updated_at: customer.updated_at
      #   }
      # end

      # def customer_params
      #   params.require(:customer).permit(:email, :name, :phone)
      # end
    end
  end
end
