require 'rails_helper'

RSpec.describe "OpenaiService Integration Test" do
  before(:each) do
    @service = OpenaiService.new
  end
  describe "#generate_response" do
    let(:prompt) { "What is the capital of France?" }
    let(:max_tokens) { 50 }
    let(:model) { "davinci" }
    let(:response) { "Paris." }

    it "generates a response from OpenAI" do
      allow(@service).to receive(:generate_response).and_return(response)
      result = @service.generate_response(prompt, max_tokens, model)
      expect(result).to eq("Paris.")
    end

    it "handles errors gracefully" do
      allow(@service.instance_variable_get(:@client)).to receive(:chat).and_raise(StandardError.new("Some error"))
      result = @service.generate_response(prompt, max_tokens, model)
      expect(result).to eq("OpenAI API Error: Some error")
    end
  end
end