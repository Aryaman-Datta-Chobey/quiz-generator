require 'rails_helper'

RSpec.feature "Delete a Quiz", type: :feature do
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
  scenario "User can delete a quiz and sees the confirmation message", js: true do
    visit quiz_path(quiz)  # Visit the quiz show page

    # Check if the delete button exists on the page
    expect(page).to have_button('Delete Quiz')

    # Stub the confirmation to automatically click 'OK'
    page.accept_confirm('Are you sure you want to delete this quiz?') do
      click_button 'Delete Quiz' 
    end

    # Expect the user to be redirected to the index page
    #expect(current_path).to eq(quizzes_path) 

    # Expect to see the flash message confirming the deletion
    expect(page).to have_content('Quiz was successfully deleted')
  end
  scenario "User clicks on delete button declines confirmation message, sucessfully NOT deleting the quiz", js: true do
    visit quiz_path(quiz)  # Visit the quiz show page

    # Check if the delete button exists on the page
    expect(page).to have_button('Delete Quiz')

    page.dismiss_confirm('Are you sure you want to delete this quiz?') do
      click_button 'Delete Quiz' 
    end

   
    expect(current_path).to eq(quiz_path(quiz))  # Expect the user to stay on the quiz show page (not redirected)

    expect(Quiz.exists?(quiz.id)).to be true # Expect the quiz to still exist in the database

    expect(page).not_to have_content('Quiz was successfully deleted')
  end
end
