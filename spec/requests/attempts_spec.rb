require 'rails_helper'

RSpec.describe "Attempts", type: :request do
  include Devise::Test::IntegrationHelpers
  
  let(:user) { User.create!(email: 'user@example.com', password: 'password') }
  let(:quiz) do
    user.quizzes.create!(
      topic: "Rspec Testing",
      difficulty: "easy",
      study_duration: 10,
      detail_level: "high",
      number_of_questions: 2,
      score: 0
    )
  end
  let(:questions) do
    [
      quiz.questions.create!(content: "What is RSpec?", options: '["A", "B", "C", "D"]', correct_answer: "A"),
      quiz.questions.create!(content: "What is TDD?", options: '["A", "B", "C", "D"]', correct_answer: "B")
    ]
  end
  let(:attempt) do
    quiz.attempts.create!(
      attempt_date: Date.today,
      time_taken: 120,
      score: 1,
      attempted_questions_attributes: [
        { question_id: questions[0].id, user_answer: "A", correct: true },
        { question_id: questions[1].id, user_answer: "C", correct: false }
      ]
    )
  end

  before do
    sign_in user
    questions # Ensure questions are created before running tests
    attempt   # Ensure the attempt is created
  end

  describe "GET /new" do
    it "returns http success" do
      get new_quiz_attempt_path(quiz)
      expect(response).to have_http_status(:success)
    end
  end

  #describe "POST /create" do
    #it "creates a new attempt and redirects" do
      #post quiz_attempts_path(quiz), params: {
       # attempt: {
         # attempted_questions_attributes: [
          #  { question_id: questions[0].id, user_answer: "A" },
          #  { question_id: questions[1].id, user_answer: "B" }
          #]
       # }
      #}
      #expect(response).to have_http_status(:redirect)
      #follow_redirect!
      #expect(response.body).to include("You scored")
    #end
  #end

  describe "GET /show" do
    it "returns http success" do
      get quiz_attempt_path(quiz, attempt)
      expect(response).to have_http_status(:success)
    end
  end
end
