class ApplicationClient
  include HTTParty

  # Override this in your API client class
  BASE_URI = nil

  class << self
    def inherited(subclass)
      super
      # Set the base URI from the subclass's BASE_URI constant
      subclass.base_uri(subclass::BASE_URI) if subclass.const_defined?(:BASE_URI) && subclass::BASE_URI
    end
  end

  # Initialize the client with optional authorization token
  # @param token [String] Bearer token for authorization
  # @param options [Hash] Additional options (headers, timeout, etc.)
  def initialize(token: nil, **options)
    @token = token
    @options = default_options.merge(options)
  end

  # Perform GET request
  # @param path [String] API endpoint path
  # @param params [Hash] Query parameters
  # @param options [Hash] Additional request options
  # @return [Hash, Array] Parsed response
  def get(path, params: {}, **options)
    request(:get, path, query: params, **options)
  end

  # Perform POST request
  # @param path [String] API endpoint path
  # @param body [Hash] Request body
  # @param options [Hash] Additional request options
  # @return [Hash, Array] Parsed response
  def post(path, body: {}, **options)
    request(:post, path, body: body, **options)
  end

  # Perform PUT request
  # @param path [String] API endpoint path
  # @param body [Hash] Request body
  # @param options [Hash] Additional request options
  # @return [Hash, Array] Parsed response
  def put(path, body: {}, **options)
    request(:put, path, body: body, **options)
  end

  # Perform PATCH request
  # @param path [String] API endpoint path
  # @param body [Hash] Request body
  # @param options [Hash] Additional request options
  # @return [Hash, Array] Parsed response
  def patch(path, body: {}, **options)
    request(:patch, path, body: body, **options)
  end

  # Perform DELETE request
  # @param path [String] API endpoint path
  # @param params [Hash] Query parameters
  # @param options [Hash] Additional request options
  # @return [Hash, Array] Parsed response
  def delete(path, params: {}, **options)
    request(:delete, path, query: params, **options)
  end

  private

  # Make HTTP request
  # @param method [Symbol] HTTP method (:get, :post, :put, :patch, :delete)
  # @param path [String] API endpoint path
  # @param options [Hash] Request options
  # @return [Hash, Array] Parsed response
  def request(method, path, **options)
    options = @options.deep_merge(options)

    # Add authorization header if token is present
    if @token
      options[:headers] ||= {}
      options[:headers]["Authorization"] = "Bearer #{@token}"
    end

    # Make the request
    response = self.class.send(method, path, **options)

    # Parse and return response
    parse_response(response)
  end

  # Parse HTTP response
  # Override this method to customize response parsing (e.g., XML parsing)
  # @param response [HTTParty::Response] HTTP response
  # @return [Hash, Array, String] Parsed response
  def parse_response(response)
    # Check if the response was successful
    unless response.success?
      handle_error(response)
    end

    # Return parsed body if available, otherwise return response body
    response.parsed_response || response.body
  end

  # Handle HTTP errors
  # Override this method to customize error handling
  # @param response [HTTParty::Response] HTTP response
  # @raise [StandardError] Error with details from response
  def handle_error(response)
    error_message = "HTTP #{response.code}: #{response.message}"

    # Try to extract error message from response body
    if response.parsed_response.is_a?(Hash)
      error_message += " - #{response.parsed_response['error'] || response.parsed_response['message']}"
    end

    raise StandardError, error_message
  end

  # Default request options
  # Override this method to customize default options
  # @return [Hash] Default options
  def default_options
    {
      headers: {
        "Content-Type" => "application/json",
        "Accept" => "application/json"
      },
      timeout: 30,
      format: :json
    }
  end
end
