require 'rails_helper'

RSpec.feature "Delete a Quiz", type: :feature do
  Capybara.reset_sessions!  # Clear cookies and session data before each test
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
      options: ["A web application framework", "A programming language", "A database", "A front-end framework"], 
      correct_answer: "A web application framework"
    ) 
  }
  
  let!(:question2) { 
    quiz.questions.create!(
      content: "Which command is used to generate a new Rails model?", 
      options: ["rails create model", "rails generate model", "rails new model", "rails model generate"], 
      correct_answer: "rails generate model"
    ) 
  }
  scenario "User can delete a quiz and sees the confirmation message" do
    visit quiz_path(quiz)  # Visit the quiz show page

    # Check if the delete button exists on the page
    expect(page).to have_button('Delete Quiz')

    # Stub the confirmation to automatically click 'OK'
    page.accept_confirm('Are you sure you want to delete this quiz?') do
      click_button 'Delete Quiz'  # Click the delete button
    end

    # Expect the user to be redirected to the index page
    expect(current_path).to eq(quizzes_path)  # or your quizzes index path

    # Expect to see the flash message confirming the deletion
    expect(page).to have_content('Quiz was successfully deleted')
  end
  ##TODO: Add scenario where user clicks no on confirmation message 
end
