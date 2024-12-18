require 'rails_helper'
RSpec.describe "Bad IDs", type: :request do
  include Devise::Test::IntegrationHelpers

  before(:each) do
    @user = User.create!(email: 'user@colgate.edu', password: 'colgate13')
    sign_in @user
  end
  describe "Bad id #index (sad_path)" do
    it 'should tell us that we are looking for an Invalid Quiz' do
      get quiz_path(1000)
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(quizzes_path)
    end
  end
end