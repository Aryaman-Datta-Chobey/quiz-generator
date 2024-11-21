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
          stream: proc do |chunk, _bytesize|
              print chunk.dig("choices", 0, "delta", "content")
          end
      }
    )
  end
end