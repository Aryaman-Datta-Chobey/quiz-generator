require 'rails_helper'

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
      #puts "attempted_question1.archived_options.inspect: #{attempted_question1.archived_options.inspect}"
      # Verify that the changes were archived
      attempted_question1.reload
      expect(attempted_question1.content).to eq("What is Ruby?")
      expect(attempted_question1.correct_answer).to eq("Programming Language")
      expect(JSON.parse(attempted_question1.options)).to eq(["Programming Language","Gemstone"])
    end

    it " does not overide previous archive for consectuive updates to same question attributes" do
      # Modify some attributes of the question
      question1.update!(content: "What is Ruby on Rails?", correct_answer: "Framework", options: JSON.generate(["Framework", "Gemstone"]))
      question1.update!(content: "What is R?", correct_answer: "Frame", options: JSON.generate(["Frame", "Gem"]))
      # Archive the changes
      #puts(attempted_question1.attributes)
      attempted_question1.reload
      #puts "attempted_question1.archived_options.inspect: #{attempted_question1.archived_options.inspect}"
      # Verify that the changes were archived
      expect(attempted_question1.content).to eq("What is Ruby?")
      expect(attempted_question1.correct_answer).to eq("Programming Language")
      expect(JSON.parse(attempted_question1.options)).to eq(["Programming Language","Gemstone"])
    end

    it "does not archive unchanged attributes" do
      # Modify only a few attributes of the question
      question2.update!(content: "What is Ruby?", correct_answer: "Programming Language")

      # Archive the changes
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
      # Modify some attributes of the question
      question1.update!(content: "What is Ruby on Rails?", correct_answer: "Framework")
      question1.destroy!
      # Archive the changes
      attempted_question1.reload
      #puts "attempted_question1.archived_options.inspect: #{attempted_question1.archived_options.inspect}"
      # Verify that the changes were archived
      expect(attempted_question1.content).to eq("What is Ruby?") # Already archived
      expect(attempted_question1.correct_answer).to eq("Programming Language") # Already archived
      expect(JSON.parse(attempted_question1.options)).to eq(["Programming Language","Gemstone"]) # Archived during destruction
    end
  end
end

