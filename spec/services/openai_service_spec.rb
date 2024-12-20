require 'rails_helper'
#Dummy comment
RSpec.describe "OpenaiService Integration Test" do
  before(:each) do
    @service = OpenaiService.new
  end
  describe "#generate_response" do
    let(:prompt) { "What is the capital of France?" }
    let(:max_tokens) { 50 }
    let(:model) { "davinci" }
    let(:response) { "Paris." }
    let(:response_hash) do
      {
        "choices" => [
          {
            "message" => {
              "content" => "Paris.\n"
            }
          }
        ]
      }
    end

    it "generates a response from OpenAI" do
      allow(@service.instance_variable_get(:@client)).to receive(:chat).and_return(response_hash)
      result = @service.generate_response(prompt, max_tokens, model)
      expect(result[:content]).to eq("Paris.")
    end

    it "handles errors gracefully" do
      allow(@service.instance_variable_get(:@client)).to receive(:chat).and_raise(StandardError.new("Some error"))
      result = @service.generate_response(prompt, max_tokens, model)
      expect(result[:content]).to eq("OpenAI API Error: Some error")
    end
  end
end