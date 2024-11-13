require 'rails_helper'

RSpec.describe "Questions", type: :request do
  describe "GET /create" do
    it "returns http success" do
      get "/questions/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/questions/destroy"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/questions/update"
      expect(response).to have_http_status(:success)
    end
  end

end
