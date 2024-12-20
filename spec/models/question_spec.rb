require 'rails_helper' #Dummy comment

RSpec.describe Question, type: :model do
  let(:user) { User.create!(email: 'test@example.com', password: 'password') }
  let(:quiz) { user.quizzes.create!(topic: "Sample Quiz", difficulty: :easy, study_duration: 30, detail_level: :high, number_of_questions: 2, score: 0, created_at: 3.hours.ago) }
  let!(:question1) { quiz.questions.create!(content: "What is Ruby?", options: ["Programming Language", "Gemstone"], correct_answer: "Programming Language", created_at: 2.hours.ago, updated_at: 2.hours.ago) }
  let!(:question2) { quiz.questions.create!(content: "What is Rails?", options: ["Framework", "Train Track"], correct_answer: "Framework", created_at: 2.hours.ago, updated_at: 2.hours.ago) }
  let!(:attempt) { quiz.attempts.create!(created_at: 1.hour.ago) }
  let!(:attempted_question1) { attempt.attempted_questions.create!(question: question1, created_at: 1.hour.ago) }
  let!(:attempted_question2) { attempt.attempted_questions.create!(question: question2, created_at: 1.hour.ago) }
  describe 'after_update callback' do
    it 'archives updated attributes in attempted_question' do
      question1.update!(content: "What is Ruby on Rails?", correct_answer: "Framework", options: JSON.generate(["Framework", "Gemstone"]))
      # Verify that the changes were archived
      attempted_question1.reload
      expect(attempted_question1.content).to eq("What is Ruby?")
      expect(attempted_question1.correct_answer).to eq("Programming Language")
      expect(JSON.parse(attempted_question1.options)).to eq(["Programming Language","Gemstone"])
    end

    it " does not overide previous archive for consectuive updates to same question attributes" do
      # Modify some attributes of the question twice
      question1.update!(content: "What is Ruby on Rails?", correct_answer: "Framework", options: JSON.generate(["Framework", "Gemstone"]))
      question1.update!(content: "What is R?", correct_answer: "Frame", options: JSON.generate(["Frame", "Gem"]))
      # Archive the changes
      attempted_question1.reload
      # Verify that the changes were archived only the first time and were not overidden
      expect(attempted_question1.content).to eq("What is Ruby?")
      expect(attempted_question1.correct_answer).to eq("Programming Language")
      expect(JSON.parse(attempted_question1.options)).to eq(["Programming Language","Gemstone"])
    end

    it "does not archive unchanged attributes" do
      # Modify only a few attributes of the question and archive
      question2.update!(content: "What is Ruby?", correct_answer: "Programming Language")
      attempted_question2.reload
      # Verify only the changed attributes are archived
      expect(attempted_question2.content).to eq("What is Rails?")
      expect(attempted_question2.correct_answer).to eq("Framework")
      expect(attempted_question2.options).to eq(nil)
    end

    it "does not update when no attributes have changed" do
      # No changes to question attributes
      expect { attempted_question1.archive_question_attributes(question1,attempted_question1) }.not_to change { attempted_question1.reload.attributes }
    end
  end

  describe 'before_destroy callback' do
    it 'archives all unarchived attributes before destruction' do
      # Destroy the question
      question1.destroy
      # Reload attempted_question and check archived attributes
      attempted_question1.reload
      expect(attempted_question1.content).to eq("What is Ruby?")
      expect(attempted_question1.correct_answer).to eq("Programming Language")
      expect(JSON.parse(attempted_question1.options)).to eq(["Programming Language","Gemstone"])
    end

    it 'does not overwrite already archived attributes during destruction' do
      # Modify some attributes of the question prior to destruction 
      question1.update!(content: "What is Ruby on Rails?", correct_answer: "Framework")
      question1.destroy!
      attempted_question1.reload
      # Verify that the intially  archived changes were not overidden
      expect(attempted_question1.content).to eq("What is Ruby?") # Already archived
      expect(attempted_question1.correct_answer).to eq("Programming Language") # Already archived
      expect(JSON.parse(attempted_question1.options)).to eq(["Programming Language","Gemstone"]) # Archived during destruction
    end
  end

  describe 'validate_and_correct_attributes before_create' do
    it 'assigns default values if attributes are missing' do
      question = quiz.questions.new
      question.save
      expect(question.content).to eq("No question stem was generated. Edit or delete this question.")
      expect(question.correct_answer).to eq("No correct answer was generated. Edit or delete this question.")
      expect(JSON.parse(question.options)).to eq(["No options were generated. Edit or delete this question","No correct answer was generated. Edit or delete this question."])
    end

    it 'corrects invalid JSON in options' do
      question = quiz.questions.new(content: "Invalid JSON Test", options: "invalid_json", correct_answer: "Answer")
      question.save
      parsed_options = JSON.parse(question.options)
      expect(parsed_options.first).to eq("Options were generated but not parseable. You can add these options manually by editing this question , or delete this question")
      expect(parsed_options.second).to eq("invalid_json")
    end

    it 'ensures the correct answer is included in options' do
      question = quiz.questions.new(content: "Include Answer Test", options: JSON.generate(["Option 1", "Option 2"]), correct_answer: "Option 3")
      question.save
      parsed_options = JSON.parse(question.options)
      expect(parsed_options).to include("Option 3")
    end

    it 'does not duplicate correct answer in options' do
      question = quiz.questions.new(content: "Avoid Duplication Test", options: JSON.generate(["Option 1", "Option 2", "Correct Answer"]), correct_answer: "Correct Answer")
      question.save
      parsed_options = JSON.parse(question.options)
      expect(parsed_options.count("Correct Answer")).to eq(1)
    end

    it 'handles empty options gracefully' do
      question = quiz.questions.new(content: "Empty Options Test", correct_answer: "Answer")
      question.save
      parsed_options = JSON.parse(question.options)
      expect(parsed_options).to include("Answer")
    end
  end
end

