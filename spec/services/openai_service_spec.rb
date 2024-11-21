require 'rails_helper'

RSpec.describe "OpenaiService Integration Test" do
  before(:each) do
    @service = OpenaiService.new
  end
  it "generates a response from OpenAI" do
    prompt = "What is the capital of France?"
    expected_response = "Paris."
    expect(@service).to receive(:generate_response).and_return(expected_response)
    response = @service.generate_response(prompt, 50, "davinci")
    expect(response).to eq(expected_response)
  end
end