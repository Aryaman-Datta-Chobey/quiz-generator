# spec/models/attempted_question_spec.rb (dummy comment)
require 'rails_helper'

RSpec.describe AttemptedQuestion, type: :model do
  let(:user) { User.create!(email: 'test@example.com', password: 'password') }
  let(:quiz) { user.quizzes.create!(topic: "Sample Quiz", difficulty: :easy, study_duration: 30, detail_level: :high, number_of_questions: 2, score: 0, created_at: 3.hours.ago) }
  let!(:question1) { quiz.questions.create!(content: "What is Ruby?", options: ["Programming Language", "Gemstone"], correct_answer: "Programming Language", created_at: 2.hours.ago, updated_at: 2.hours.ago) }
  let!(:question2) { quiz.questions.create!(content: "What is Rails?", options: ["Framework", "Train Track"], correct_answer: "Framework", created_at: 2.hours.ago, updated_at: 2.hours.ago) }
  let!(:attempt) { quiz.attempts.create!(created_at: 1.hour.ago) }
  let!(:attempted_question1) { attempt.attempted_questions.create!(question: question1, created_at: 1.hour.ago) }
  let!(:attempted_question2) { attempt.attempted_questions.create!(question: question2, created_at: 1.hour.ago) }

  describe "#archive_question_attributes" do
    it "archives changes to relevant question attributes" do
      #puts "question1.options.inspect before: #{question1.options.inspect}"
      # Modify some attributes of the question
      question1.update!(content: "What is Ruby on Rails?", correct_answer: "Framework", options: JSON.generate(["Framework", "Gemstone"]))
      #puts "question1.options.inspect after: #{question1.options.inspect}"
      # Archive the changes
      attempted_question1.reload
      #puts "attempted_question1.archived_options.inspect: #{attempted_question1.archived_options.inspect}"
      # Verify that the changes were archived
      expect(attempted_question1.content).to eq("What is Ruby?")
      expect(attempted_question1.correct_answer).to eq("Programming Language")
      expect(JSON.parse(attempted_question1.options)).to eq(["Programming Language","Gemstone"])
    end

    it " does not overide previous archive for consectuive updates to same changes to same question attributes" do
      # Modify some attributes of the question
      question1.update!(content: "What is Ruby on Rails?", correct_answer: "Framework", options: JSON.generate(["Framework", "Gemstone"]))
      # Archive the changes
      attempted_question1.reload#attempted_question1.archive_question_attributes(question1,attempted_question1)
      question1.update!(content: "What is R?", correct_answer: "Frame", options: JSON.generate(["Frame", "Gem"]))
      # Archive the changes
      puts(attempted_question1.attributes)
      attempted_question1.archive_question_attributes(question1,attempted_question1)
      #puts "attempted_question1.archived_options.inspect: #{attempted_question1.archived_options.inspect}"
      # Verify that the changes were archived
      attempted_question1.reload
      expect(attempted_question1.content).to eq("What is Ruby?")
      expect(attempted_question1.correct_answer).to eq("Programming Language")
      expect(JSON.parse(attempted_question1.options)).to eq(["Programming Language","Gemstone"])
    end

    it "does not archive unchanged attributes" do
      # Modify only a few attributes of the question
      question2.update!(content: "What is Ruby?", correct_answer: "Programming Language")

      # Archive the changes
      attempted_question2.archive_question_attributes(question2,attempted_question2)

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
end

