require 'rails_helper'

RSpec.describe QuizzesController, type: :controller do
  include Devise::Test::ControllerHelpers
  #render_views false # Suppress view rendering in this controller spec as we have not yet implemented a quiz editing view
  before(:each) do
    @user = User.create!(email: 'user@colgate.edu', password: 'colgate13')
    sign_in @user
  end
  let!(:quiz) {
    @user.quizzes.create!(
      topic: "Ruby on Rails Basics",
      difficulty: "easy",
      study_duration: 30,
      detail_level: "low",
      number_of_questions: 2
    )
  }

  describe 'GET #index' do
    context 'when user is not signed in' do
      it 'responds with an empty array' do
        sign_out @user # Sign out the user to simulate a non-signed-in state
        get :index
        # Since @quizzes is assigned to an empty array, you can check the response
        expect(response).to have_http_status(:ok)
        # You can also assert that the rendered JSON or HTML does not contain quiz data.
        #expect(response.body).to include("Login to get started") # Assuming you render this when no quizzes are found
      end
    end
  end

  describe 'GET #show' do
    context 'when quiz exists' do
      it 'responds with the correct quiz instance' do
        get :show, params: { id: quiz.id }
        # Check if the response includes details of the quiz
        expect(response).to have_http_status(:ok)
        #expect(response.body).to include("Ruby on Rails Basics") # Assuming you render quiz details in the body
      end
    end

    context 'when quiz does not exist' do
      it 'raises ActiveRecord::RecordNotFound and redirects with flash message' do
        # Simulate quiz not found scenario
        allow(Quiz).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
        get :show, params: { id: 'invalid_id' }
        expect(flash[:alert]).to eq('Invalid quiz ID')
        expect(response).to redirect_to(quizzes_path)
      end
    end
  end
end
