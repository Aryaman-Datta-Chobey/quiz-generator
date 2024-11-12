require 'rails_helper'
RSpec.describe "Quizzes", type: :system do
    include Devise::Test::IntegrationHelpers
    let(:user) { User.create!(email: 'user@example.com', password: 'password') }
    let(:user1) { User.create!(email: 'user1@example.com', password: 'password') }
  
    before do
      driven_by(:rack_test)
      user.quizzes.create!(topic: "Rspec Testing", difficulty: "easy", study_duration: 9, detail_level: "high", number_of_questions: 100, score: 0)
      user.quizzes.create!(topic: "Passing Rspec Tests", difficulty: "hard", study_duration: 10, detail_level: "high", number_of_questions: 100, score: 0)
      user1.quizzes.create!(topic: "Other user's rspec test", difficulty: "hard", study_duration: 10, detail_level: "high", number_of_questions: 100, score: 0)
    end
  
    it 'filters quizzes by search string and only displays quizzes owned by the logged-in user' do
      # Sign in as user
      sign_in user
      
      # Visit the quizzes index page
      visit quizzes_path
  
      # Perform search
      fill_in 'query', with: 'Passing Rspec'
      click_button 'Find Quiz'
  
      # Expectations
      expect(page).to have_content("Passing Rspec Tests")
      expect(page).to have_content("Rspec Testing")
      expect(page).not_to have_content("Other user's rspec test")  # Should not see user1's quiz
    end
  end
  