# Example API client for OpenAI API
# https://platform.openai.com/docs/api-reference
#
# Usage:
#   client = OpenAiClient.new(token: "sk-...")
#   response = client.create_completion(model: "gpt-4", messages: [{role: "user", content: "Hello!"}])
#
class OpenAiClient < ApplicationClient
  BASE_URI = "https://api.openai.com/v1"

  # Create a chat completion
  # POST /chat/completions
  # Params:
  #   model: (required) ID of the model to use (e.g., "gpt-4", "gpt-3.5-turbo")
  #   messages: (required) Array of message objects with role and content
  #   temperature: (optional) Sampling temperature between 0 and 2
  #   max_tokens: (optional) Maximum number of tokens to generate
  def create_completion(model:, messages:, **options)
    post "/chat/completions", body: {
      model: model,
      messages: messages,
      **options
    }
  end

  # Create an image with DALL-E
  # POST /images/generations
  # Params:
  #   prompt: (required) Text description of the desired image
  #   n: (optional) Number of images to generate (1-10)
  #   size: (optional) Size of the images ("256x256", "512x512", "1024x1024")
  def create_image(prompt:, n: 1, size: "1024x1024", **options)
    post "/images/generations", body: {
      prompt: prompt,
      n: n,
      size: size,
      **options
    }
  end

  # List available models
  # GET /models
  def models
    get "/models"
  end

  # Get details about a specific model
  # GET /models/:id
  def model(id)
    get "/models/#{id}"
  end

  # Create embeddings
  # POST /embeddings
  # Params:
  #   model: (required) ID of the model to use (e.g., "text-embedding-ada-002")
  #   input: (required) Input text to get embeddings for
  def create_embedding(model:, input:, **options)
    post "/embeddings", body: {
      model: model,
      input: input,
      **options
    }
  end

  # Create a moderation
  # POST /moderations
  # Params:
  #   input: (required) Text to classify
  #   model: (optional) Model to use (default: "text-moderation-latest")
  def create_moderation(input:, model: "text-moderation-latest")
    post "/moderations", body: {
      input: input,
      model: model
    }
  end

  # List files
  # GET /files
  def files
    get "/files"
  end

  # Upload a file
  # POST /files
  # Note: This is a simplified example. For actual file uploads, you'll need to
  # customize the request to handle multipart/form-data
  def upload_file(file:, purpose:)
    post "/files", body: {
      file: file,
      purpose: purpose
    }
  end

  # Delete a file
  # DELETE /files/:id
  def delete_file(id)
    delete "/files/#{id}"
  end
end
