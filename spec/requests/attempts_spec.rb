require 'rails_helper'

RSpec.describe "Attempts", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/attempts/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/attempts/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/attempts/show"
      expect(response).to have_http_status(:success)
    end
  end

end
