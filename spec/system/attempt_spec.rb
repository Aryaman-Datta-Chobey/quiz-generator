require 'rails_helper'

RSpec.describe "Attempts", type: :system do
  include Devise::Test::IntegrationHelpers

  let(:user) { User.create!(email: 'user@example.com', password: 'password') }
  let(:quiz) {
    user.quizzes.create!(
      topic: "Ruby on Rails Basics",
      difficulty: "easy",
      study_duration: 20,
      detail_level: "high",
      number_of_questions: 3
    )
  }
  let!(:question_1) { quiz.questions.create!(content: "What does Rails stand for?", options: '["MVC framework", "A gem", "A database", "A language"]', correct_answer: "MVC framework") }
  let!(:question_2) { quiz.questions.create!(content: "What is ActiveRecord?", options: '["A Ruby gem", "An ORM", "A database", "A library"]', correct_answer: "An ORM") }
  let!(:question_3) { quiz.questions.create!(content: "What is a migration?", options: '["A change to the database schema", "A Ruby gem", "A new feature", "A bug fix"]', correct_answer: "A change to the database schema") }

  before do
    driven_by(:rack_test)
    sign_in user
  end

  it "creates an attempt and displays the score and time taken" do
    # Start the quiz (simulating setting start time)
    quiz_start_time = Time.now.to_f
    visit new_quiz_attempt_path(quiz)

    # Simulate quiz start time by passing it as a hidden field
    # page.execute_script("document.querySelector('form').insertAdjacentHTML('beforeend', '<input type=\"hidden\" name=\"quiz_start_time\" value=\"#{quiz_start_time}\">')")

    # Fill in answers for the questions
    all(".mb-4").each_with_index do |question_div, index|
      within(question_div) do
        puts "This is the div: #{question_div.text}"
        case index
        when 0
          choose "MVC framework"
        when 1
          choose "An ORM"
        when 2
          choose "A bug fix"
        end
      end
    end

    # Submit the form
    click_button "Submit Quiz Attempt"

    # Validate the results
    expect(page).to have_content("You scored 2 out of 3.") # Adjust score based on test answers
    expect(page).to have_content("Time taken:") # Validate duration message
    expect(page).to have_content("Attempt Details")
    # expect(page).to have_content("Attempted Questions")
    expect(quiz.attempts.count).to eq(1)

    # Validate that AttemptedQuestions were created
    attempt = quiz.attempts.first
    expect(attempt.attempted_questions.count).to eq(3)
    expect(attempt.attempted_questions.find_by(question: question_1).correct).to eq(true)
    expect(attempt.attempted_questions.find_by(question: question_2).correct).to eq(true)
    expect(attempt.attempted_questions.find_by(question: question_3).correct).to eq(false)
  end
end
