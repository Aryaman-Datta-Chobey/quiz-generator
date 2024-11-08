require 'rails_helper'

RSpec.describe "QuizCreation", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe 'create a new quiz' do
    it 'successful create' do
      visit new_quiz_path
      fill_in 'Topic', with: 'Science Quiz'
      select 'Easy', from: 'Difficulty'
      fill_in 'Study duration', with: 60
      select 'High', from: 'Detail level'
      fill_in 'Number of questions', with: 10
      click_on 'Create Quiz'
      expect(page).to have_content('Quiz was successfully generated')
      expect(page.current_path).to eq(quizzes_path)
      expect(page).to have_content('Science Quiz')
    end

    it 'should flash error on failure' do
      visit new_quiz_path
      fill_in 'Topic', with: 'Science Quiz'
      select 'Hard', from: 'Difficulty'
      fill_in 'Study duration', with: 60
      select 'Low', from: 'Detail level'
      fill_in 'Number of questions', with: 10

      s = Quiz.new
      expect(Quiz).to receive(:new).and_return(s)
      expect(s).to receive(:save).and_return(false)

      click_on 'Create Quiz'
      expect(page.current_path).to eq(quizzes_path)
      expect(page).to have_content('Quiz could not be created')
    end
  end
end
