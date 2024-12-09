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
    response.dig.choices.first.delta.content
    response
    rescue StandardError => e
      Rails.logger.error("OpenAI API Error: #{e.message}")
      "Sorry, something went wrong."
    end
  end