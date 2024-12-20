# app/services/openai_service.rb
require "openai"

class OpenaiService
  REQUESTS_PER_MINUTE = 29 #1 less than official limit of 30 for rate limit error preventative pausing
  TOKENS_PER_MINUTE = 4600 # 400 tokens less than official limit of 5000 for rate limit error prevention by pausing

  def initialize
    @client = OpenAI::Client.new(
      access_token: ENV['GROQ_API_KEY'],
      uri_base: "https://api.groq.com/openai",
      log_errors: true
    )
    @requests_made = 0
    @tokens_used = 0
    @start_time = Time.now
  end

  def generate_response(prompt, max_tokens, model)
    reset_limits_if_needed

    begin
      response = @client.chat(
        parameters: {
          model: model,
          response_format: { type: "json_object" },
          messages: [{ role: "user", content: prompt }],
          temperature: 0.7,
          max_tokens: max_tokens,
        }
      )

      # Extract token usage
      input_tokens = response.dig("usage", "prompt_tokens").to_i
      output_tokens = response.dig("usage", "completion_tokens").to_i
      total_tokens = response.dig("usage", "total_tokens").to_i

      # Update usage counters
      @requests_made += 1
      @tokens_used += total_tokens

      # Log token usage
      Rails.logger.info("OpenAI Call: Input Tokens=#{input_tokens}, Output Tokens=#{output_tokens}, Average Tokens/Question=#{output_tokens / (max_tokens.nonzero? || 1)}")

      # Enforce rate limiting
      enforce_rate_limits

      content = response.dig("choices", 0, "message", "content")
      cleaned_content = content.gsub("\n", "")
      { content: cleaned_content, input_tokens: input_tokens, output_tokens: output_tokens }
    rescue StandardError => e
      Rails.logger.error("OpenAI API Error: #{e.message}")
      { content: "OpenAI API Error: #{e.message}", input_tokens: 0, output_tokens: 0 }
    end
  end

  private

  def reset_limits_if_needed
    if Time.now - @start_time >= 60
      @start_time = Time.now
      @requests_made = 0
      @tokens_used = 0
    end
  end

  def enforce_rate_limits
    if @requests_made >= REQUESTS_PER_MINUTE || @tokens_used >= TOKENS_PER_MINUTE
      sleep_duration = 60 - (Time.now - @start_time)
      Rails.logger.info("Rate limit reached. Pausing for #{sleep_duration.round(2)} seconds.")
      sleep(sleep_duration) if sleep_duration > 0
      reset_limits_if_needed
    end
  end
end
