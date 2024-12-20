require 'rails_helper'

RSpec.describe "QuizCreation", type: :system do
  include Devise::Test::IntegrationHelpers
  before do
    driven_by(:rack_test)
  end
  before(:each) do
    @user = User.create!(email: 'user@colgate.edu', password: 'colgate13')
    sign_in @user
  end
  let(:mock_response) do
    {
      "questions" => [
        {
          "content" => "What is the output of the following Ruby code?\n\nputs 5 + 3",
          "options" => [ "8", "53", "3", "5" ],
          "correct_answer" => "8"
        },
        {
          "content" => "Which of the following is NOT a Ruby data type?",
          "options" => [ "String", "Float", "Bignum", "Integer" ],
          "correct_answer" => "Bignum"
        }
      ]
    }.to_json
  end

  describe 'create a new quiz' do
    it 'successful create' do
      visit new_quiz_path
      fill_in 'Topic', with: 'Science Quiz'
      select 'Easy', from: 'Difficulty'
      fill_in 'Study Duration (mins)', with: 60
      select 'High', from: 'Detail Level'
      fill_in 'Number of Questions', with: 10
      allow_any_instance_of(OpenaiService).to receive(:generate_response).and_return(mock_response)
      click_on 'Fetch Quiz'
      expect(page).to have_content('Quiz was successfully generated')
      expect(page.current_path).to eq(quiz_path(Quiz.last))
      expect(page).to have_content('Science Quiz')
    end

    it 'should flash error on failure' do
      visit new_quiz_path
      fill_in 'Topic', with: 'Science Quiz'
      select 'Hard', from: 'Difficulty'
      fill_in 'Study Duration (mins)', with: 60
      select 'Low', from: 'Detail Level'
      fill_in 'Number of Questions', with: 10
      allow_any_instance_of(OpenaiService).to receive(:generate_response).and_return(mock_response)
      allow_any_instance_of(Quiz).to receive(:save).and_return(false)
      click_on 'Fetch Quiz'
      expect(page).to have_content('Quiz cannot be saved. Please try again.')
      expect(page.current_path).to eq(quizzes_path)
    end

    it 'should flash error on JSON parse failure' do
      visit new_quiz_path
      fill_in 'Topic', with: 'Science Quiz'
      select 'Easy', from: 'Difficulty'
      fill_in 'Study Duration (mins)', with: 60
      select 'High', from: 'Detail Level'
      fill_in 'Number of Questions', with: 10
      allow_any_instance_of(OpenaiService).to receive(:generate_response).and_return(JSON::ParserError)

      click_on 'Fetch Quiz'
      expect(page.current_path).to eq(quizzes_path)
      expect(page).to have_content('Quiz generation failed. Please reduce the number of questions and try again.')
    end
  end
  describe 'model methods for text representation' do
    it 'returns "Not specified" when difficulty is nil' do
      quiz = Quiz.new(detail_level: 'low') # Missing `difficulty`
      expect(quiz.difficulty_text).to eq('Not specified')
    end

    it 'returns "Not specified" when detail_level is nil' do
      quiz = Quiz.new(difficulty: 'easy') # Missing `detail_level`
      expect(quiz.detail_level_text).to eq('Not specified')
    end
  end
end
