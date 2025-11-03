require "test_helper"

class OpenAiClientTest < ActiveSupport::TestCase
  setup do
    @client = OpenAiClient.new(token: "sk-test123")
    @base_url = "https://api.openai.com/v1"
  end

  test "create_completion makes POST request to chat/completions" do
    stub_request(:post, "#{@base_url}/chat/completions")
      .with(
        headers: { "Authorization" => "Bearer sk-test123" },
        body: {
          model: "gpt-4",
          messages: [{ role: "user", content: "Hello!" }]
        }.to_json
      )
      .to_return(
        status: 200,
        body: {
          id: "chatcmpl-123",
          choices: [
            {
              message: {
                role: "assistant",
                content: "Hello! How can I help you today?"
              }
            }
          ]
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    response = @client.create_completion(
      model: "gpt-4",
      messages: [{ role: "user", content: "Hello!" }]
    )

    assert_equal "chatcmpl-123", response["id"]
    assert_equal "assistant", response["choices"].first["message"]["role"]
  end

  test "create_image makes POST request to images/generations" do
    stub_request(:post, "#{@base_url}/images/generations")
      .with(
        body: {
          prompt: "A beautiful sunset",
          n: 1,
          size: "1024x1024"
        }.to_json
      )
      .to_return(
        status: 200,
        body: {
          data: [
            {
              url: "https://example.com/image.png"
            }
          ]
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    response = @client.create_image(prompt: "A beautiful sunset")

    assert_equal "https://example.com/image.png", response["data"].first["url"]
  end

  test "models returns list of available models" do
    stub_request(:get, "#{@base_url}/models")
      .to_return(
        status: 200,
        body: {
          data: [
            { id: "gpt-4", object: "model" },
            { id: "gpt-3.5-turbo", object: "model" }
          ]
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    response = @client.models

    assert_equal 2, response["data"].length
    assert_equal "gpt-4", response["data"].first["id"]
  end

  test "model returns details about specific model" do
    stub_request(:get, "#{@base_url}/models/gpt-4")
      .to_return(
        status: 200,
        body: {
          id: "gpt-4",
          object: "model",
          owned_by: "openai"
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    response = @client.model("gpt-4")

    assert_equal "gpt-4", response["id"]
    assert_equal "openai", response["owned_by"]
  end

  test "create_embedding makes POST request to embeddings" do
    stub_request(:post, "#{@base_url}/embeddings")
      .with(
        body: {
          model: "text-embedding-ada-002",
          input: "Hello world"
        }.to_json
      )
      .to_return(
        status: 200,
        body: {
          data: [
            {
              embedding: [0.1, 0.2, 0.3],
              index: 0
            }
          ]
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    response = @client.create_embedding(
      model: "text-embedding-ada-002",
      input: "Hello world"
    )

    assert_equal 3, response["data"].first["embedding"].length
  end

  test "create_moderation makes POST request to moderations" do
    stub_request(:post, "#{@base_url}/moderations")
      .with(
        body: {
          input: "I want to kill them.",
          model: "text-moderation-latest"
        }.to_json
      )
      .to_return(
        status: 200,
        body: {
          results: [
            {
              flagged: true,
              categories: {
                violence: true
              }
            }
          ]
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    response = @client.create_moderation(input: "I want to kill them.")

    assert_equal true, response["results"].first["flagged"]
    assert_equal true, response["results"].first["categories"]["violence"]
  end

  test "handles API errors gracefully" do
    stub_request(:post, "#{@base_url}/chat/completions")
      .to_return(
        status: 401,
        body: {
          error: {
            message: "Invalid API key",
            type: "invalid_request_error"
          }
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    error = assert_raises(StandardError) do
      @client.create_completion(
        model: "gpt-4",
        messages: [{ role: "user", content: "Hello!" }]
      )
    end

    assert_match /401/, error.message
  end
end
