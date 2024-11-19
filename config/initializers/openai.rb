require "openai"

OpenAI.configure do |config|
  config.access_token = ENV['GROQ_API_KEY']
end