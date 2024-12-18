require "openai"

class OpenaiService
  def initialize
    @client = OpenAI::Client.new(
      access_token: ENV['GROQ_API_KEY'],
      uri_base: "https://api.groq.com/openai",
      log_errors: true
    )
  end

  def generate_response(prompt, max_tokens, model)
    response = @client.chat(
      parameters: {
          model: model,
          messages: [{ role: "user", content: prompt}],
          temperature: 0.7,
          max_tokens: max_tokens,
      }
    )
    content = response.dig("choices", 0, "message", "content")
    cleaned_content = content.gsub("\n", "")
    cleaned_content
    rescue StandardError => e
      "OpenAI API Error: #{e.message}"
    end
  end