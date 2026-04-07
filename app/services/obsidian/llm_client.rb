require "net/http"
require "json"

module Obsidian
  class LlmClient
    class Error < StandardError; end

    def initialize(user)
      @endpoint = user.llm_endpoint
      @api_key = user.llm_api_key
      @model = user.llm_model
    end

    def configured?
      @endpoint.present? && @model.present?
    end

    def chat(prompt)
      raise Error, "LLM not configured" unless configured?

      uri = URI(@endpoint)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.read_timeout = 120
      http.open_timeout = 10

      request = Net::HTTP::Post.new(uri.path.presence || "/v1/chat/completions")
      request["Content-Type"] = "application/json"
      request["Authorization"] = "Bearer #{@api_key}" if @api_key.present?

      request.body = {
        model: @model,
        messages: [ { role: "user", content: prompt } ],
        temperature: 0.3
      }.to_json

      response = http.request(request)

      unless response.is_a?(Net::HTTPSuccess)
        raise Error, "LLM returned #{response.code}: #{response.body.truncate(200)}"
      end

      parsed = JSON.parse(response.body)
      parsed.dig("choices", 0, "message", "content") || raise(Error, "Empty LLM response")
    end

    def test_connection
      chat("Respond with exactly: OK")
      true
    rescue Error => e
      raise e
    rescue => e
      raise Error, "Connection failed: #{e.message}"
    end
  end
end
