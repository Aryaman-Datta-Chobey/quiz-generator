require 'rails_helper'

RSpec.feature "Attempt a Quiz", type: :feature do
  include Devise::Test::IntegrationHelpers
  Capybara.reset_sessions!  # Clear cookies and session data before each test
  before(:each) do
    @user = User.create!(email: 'user@colgate.edu', password: 'colgate13')
    sign_in @user
  end
  let!(:quiz) {
    Quiz.create!(
      topic: "Ruby on Rails Basics",
      difficulty: "easy",
      study_duration: 30,
      detail_level: "low",
      number_of_questions: 2
    )
  }

  let!(:question1) {
    quiz.questions.create!(
      content: "What is Rails?",
      options: [ "A web application framework", "A programming language", "A database", "A front-end framework" ],
      correct_answer: "A web application framework"
    )
  }

  let!(:question2) {
    quiz.questions.create!(
      content: "Which command is used to generate a new Rails model?",
      options: [ "rails create model", "rails generate model", "rails new model", "rails model generate" ],
      correct_answer: "rails generate model"
    )
  }

  scenario "User views quiz details" do
    visit quiz_path(quiz)

    expect(page).to have_content("Ruby on Rails Basics Quiz")
    expect(page).to have_content("Difficulty: Easy")
    expect(page).to have_content("Study Duration: 30 minutes")
    expect(page).to have_content("Detail Level: Low")
    expect(page).to have_content("Number of Questions: 2")
  end

  scenario " For MCQs User can only select one option per question (radio buttons)" do
    visit quiz_path(quiz)
    # Verify single-select for question 1
    find("input[name='answers[#{question1.id}]'][value='A web application framework']").choose
    find("input[name='answers[#{question1.id}]'][value='A programming language']").choose

    # Ensure only one option is selected at a time
    expect(find("input[name='answers[#{question1.id}]'][value='A programming language']")).to be_checked
    expect(find("input[name='answers[#{question1.id}]'][value='A web application framework']")).not_to be_checked
  end

  scenario "User tries to submit without answering all questions and sees error", js: true do
    visit quiz_path(quiz)

    # Answer only the first question
    find("input[name='answers[#{question1.id}]'][value='A web application framework']").choose
    click_button "Submit Quiz"

    # expect(page).to have_content("Please select one of these options.")
    expect(current_path).to eq(quiz_path(quiz))
  end

  scenario "User submits the quiz with all questions answered and sees score and time" do
    visit quiz_path(quiz)

    # Answer all questions
    find("input[name='answers[#{question1.id}]'][value='A web application framework']").choose
    find("input[name='answers[#{question2.id}]'][value='rails generate model']").choose

    # Submit the quiz
    click_button "Submit Quiz"

    # Expect flash message with the score and time taken
    expect(page).to have_content("You scored 2 out of 2.")
    expect(page).to have_content("Time taken:")
    # verify that the study_duration atribute was modified by the controller
    # quiz.reload
    # expect(quiz.study_duration).not_to eq(30)
  end
end
