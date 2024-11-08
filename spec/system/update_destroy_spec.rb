require 'rails_helper'

RSpec.describe QuizzesController, type: :controller do
  render_views false # Suppress view rendering in this controller spec as we have not yet implemented a quiz editing view

  let!(:quiz) {
    Quiz.create!(
      topic: "Ruby on Rails Basics",
      difficulty: "easy",
      study_duration: 30,
      detail_level: "low",
      number_of_questions: 2
    )
  }

  describe 'PATCH #update' do
    context 'with valid parameters' do
      it 'updates the quiz' do
        patch :update, params: { id: quiz.id, quiz: { topic: "Updated Topic", study_duration: 300 } }

        quiz.reload

        expect(quiz.topic).to eq("Updated Topic")
        expect(quiz.study_duration).to eq(300)
      end
    end
=begin #unccoment once we have an edit view
    context 'with invalid parameters' do
      it 'does not update the quiz' do
        patch :update, params: { id: quiz.id, quiz: { difficulty: "", detail_level: "" } }

        quiz.reload

        expect(quiz.difficulty).to eq("easy")
        expect(quiz.detail_level).to eq("low")
        expect(response).to have_http_status(:unprocessable_entity)
      end 
=end
    describe 'DELETE #destroy' do
    it 'deletes the quiz and redirects to the index with a success notice' do
    # Ensure the quiz exists before deletion
    expect(Quiz.exists?(quiz.id)).to be true

    # Perform the delete action
    delete :destroy, params: { id: quiz.id }

    # Confirm the quiz is deleted from the database
    expect(Quiz.exists?(quiz.id)).to be false

    # Confirm the redirection to the quizzes index
    expect(response).to redirect_to(quizzes_url)

    # Confirm the success notice
    expect(flash[:notice]).to eq("Quiz was successfully deleted.")
    end
    end
    
end
end

