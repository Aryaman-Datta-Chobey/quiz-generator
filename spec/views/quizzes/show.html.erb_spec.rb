require 'rails_helper'

RSpec.describe "quizzes/show.html.erb", type: :view do
  include Devise::Test::ControllerHelpers

  let(:user) { User.create!(email: 'user@example.com', password: 'password') }
  # let(:quiz) { user.quizzes.create!(
  # topic: "Ruby on Rails Basics",
  # difficulty: "easy",
  # study_duration: 20,
  # detail_level: "high",
  # number_of_questions: 10,
  # score: 0) }

  # let(:attempt_1) { quiz.attempts.create!(attempt_date: "2024-11-01", time_taken: 300, score: 8) }
  # let(:attempt_2) { quiz.attempts.create!(attempt_date: "2024-11-05", time_taken: 250, score: 9) }

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
  let(:attempt_1) do
    quiz.attempts.create!(
      attempt_date: "2024-11-01",
      time_taken: 300,
      score: 1,
      attempted_questions_attributes: [
        { question_id: questions[0].id, user_answer: "A", correct: true },
        { question_id: questions[1].id, user_answer: "C", correct: false }
      ]
    )
  end
  let(:attempt_2) do
    quiz.attempts.create!(
      attempt_date: "2024-11-05",
      time_taken: 250,
      score: 2,
      attempted_questions_attributes: [
        { question_id: questions[0].id, user_answer: "A", correct: true },
        { question_id: questions[1].id, user_answer: "B", correct: true }
      ]
    )
  end

  context "when user is logged in" do
    before do
      sign_in user
      assign(:quiz, quiz)
      render
    end

    it "displays the quiz topic" do
      expect(rendered).to match(/Rspec Testing/)
    end

    it "displays the quiz difficulty" do
      expect(rendered).to match(/Difficulty: Easy/)
    end

    it "displays the quiz study duration" do
      expect(rendered).to match(/Study Duration: 10 minutes/)
    end

    it "displays the quiz detail level" do
      expect(rendered).to match(/Detail Level: High/)
    end

    it "displays the number of questions" do
      expect(rendered).to match(/Number of Questions: 2/)
    end

    it "displays a button to attempt the quiz" do
      expect(rendered).to have_link("Attempt Quiz", href: new_quiz_attempt_path(quiz))
    end

    it "displays a button to delete the quiz" do
      expect(rendered).to have_button("Delete Quiz")
    end

    it "displays previous attempts" do
      assign(:quiz, quiz) # ensuring @quiz is available
      quiz.attempts << attempt_1
      quiz.attempts << attempt_2
      render
      expect(rendered).to match(/Previous Attempts/)
      expect(rendered).to match(/2024-11-01/) # Attempt date
      expect(rendered).to match(/1/) # score
      expect(rendered).to match(/300 seconds/)
      expect(rendered).to match(/View Attempt/)
      expect(rendered).to match(/2024-11-05/) # Attempt date
      expect(rendered).to match(/2/) # score
      expect(rendered).to match(/250 seconds/)
    end

    it "does not display previous attempts if none exist" do
      # quiz.attempts.destroy_all
      attempt_1.destroy!
      attempt_2.destroy!
      render
      expect(rendered).to match(/No attempts have been made for this quiz yet./)
    end
  end
end
