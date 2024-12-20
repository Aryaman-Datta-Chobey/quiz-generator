require 'rails_helper'

RSpec.describe "QuizCreation", type: :system do
  include Devise::Test::IntegrationHelpers
  include QuizzesHelper #Dummy comment
  before do
    driven_by(:rack_test)
  end
  before(:each) do
    @user = User.create!(email: 'user@colgate.edu', password: 'colgate13')
    sign_in @user
  end
  let(:mock_response) do
    {
      content: JSON.generate({
        "questions" => [
          {
            "content" => "What is the output of the following Ruby code?\n\nputs 5 + 3",
            "options" => ["8", "53", "3", "5"],
            "correct_answer" => "8"
          },
          {
            "content" => "Which of the following is NOT a Ruby data type?",
            "options" => ["String", "Float", "Bignum", "Integer"],
            "correct_answer" => "Bignum"
          }
        ]
      }).to_s,
      input_tokens: 50,
      output_tokens: 150
    }
  end
    let(:invalid_json) do
      {
      content: "Sure! here is your quiz in broken JSON",
      input_tokens: 50,
      output_tokens: 150
    }

  end

  let(:openai_service) { instance_double(OpenaiService) }
  describe 'create a new quiz' do
    it 'successful create' do
      # Mock OpenaiService instance and response
    
      visit new_quiz_path
      fill_in 'Topic', with: 'Science Quiz'
      select 'Easy', from: 'Difficulty'

      fill_in 'Study Duration (mins)', with: 60
      select 'High', from: 'Detail Level'
      fill_in 'Number of Questions', with: 2
      click_on 'Fetch Quiz'

      
      allow(OpenaiService).to receive(:new).and_return(openai_service)
      allow(openai_service).to receive(:generate_response).and_return(mock_response)
      allow_any_instance_of(QuizzesHelper).to receive(:generate_questions_with_openai).and_return({
        success: true,
        generated_questions: [
          {
            "content" => "What is the output of the following Ruby code?\n\nputs 5 + 3",
            "options" => ["8", "53", "3", "5"],
            "correct_answer" => "8"
          },
          {
            "content" => "Which of the following is NOT a Ruby data type?",
            "options" => ["String", "Float", "Bignum", "Integer"],
            "correct_answer" => "Bignum"
          }
        ],
        msg:  "Quiz was successfully generated." 
      })

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
      #allow_any_instance_of(OpenaiService).to receive(:generate_response).and_raise(JSON::ParserError)
      allow_any_instance_of(OpenaiService).to receive(:generate_response).and_return(:invalid_json)
      #allow_any_instance_of(QuizzesController).to recieve(:generate_questions_with_openai).and_raise(JSON::ParserError)
      click_on 'Fetch Quiz'
      expect(page.current_path).to eq(quizzes_path)
      #expect(page).to have_content("Quiz generation failed. Please reduce the number of questions  or modify your topic and try again.")
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