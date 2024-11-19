require 'openai'

class OpenAIService
    def initialize
      @client = OpenAI::Client.new(
        access_token: ENV['GROQ_API_KEY'],
        uri_base: "https://api.groq.com/openai"
      )
    end
  
    def generate_response(prompt, model = 'text-davinci-003')
      response = @client.completions(
        parameters: {
          model: model,
          prompt: prompt,
          max_tokens: 150
        }
      )
      response['choices'].first['text'].strip
    rescue StandardError => e
      Rails.logger.error("OpenAI API Error: #{e.message}")
      "Sorry, something went wrong."
    end
  end