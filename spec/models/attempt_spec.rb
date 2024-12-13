# spec/models/attempt_spec.rb
require 'rails_helper'

RSpec.describe Attempt, type: :model do
  let(:user) { User.create!(email: 'test@example.com', password: 'password') }
  let(:quiz) { user.quizzes.create!(topic: "Sample Quiz", difficulty: :easy, study_duration: 30, detail_level: :high, number_of_questions: 2, score: 0,created_at: 3.hours.ago) }
  let!(:question1) { quiz.questions.create!(content: "What is Ruby?", options: ["Programming Language", "Gemstone"], correct_answer: "Programming Language",created_at: 2.hours.ago,updated_at: 2.hours.ago) }
  let!(:question2) { quiz.questions.create!(content: "What is Rails?", options: ["Framework", "Train Track"], correct_answer: "Framework",created_at: 2.hours.ago,updated_at: 2.hours.ago) }
  let!(:attempt) { quiz.attempts.create!(created_at: 1.hour.ago) }
  let!(:attempted_question1) { attempt.attempted_questions.create!(question: question1,created_at: 1.hour.ago) }
  let!(:attempted_question2) { attempt.attempted_questions.create!(question: question2,created_at: 1.hour.ago) }

  before do
    # Modify and remove questions to test methods
    question1.update!(updated_at: Time.now)
  end

  describe "#original_questions" do
    it "returns questions that have not been modified since the attempt was created" do
      # Debugging outputs
      #puts "Attempt Created At: #{attempt.created_at}"
      #puts "Question1 Updated At: #{question1.updated_at}"
      #puts "Question2 Updated At: #{question2.updated_at}"
      expect(question1.updated_at).to be > question2.updated_at
      expect(question1.updated_at).to be > attempt.created_at
      expect(question2.updated_at).to be <= attempt.created_at
      expect(attempt.original_questions).to eq([attempted_question2])
    end
  end


  describe "#modified_questions" do
    it "returns questions that have been updated after the attempt was created" do
      #puts "Attempt Created At: #{attempt.created_at}"
      #puts "Question1 Updated At: #{question1.updated_at}"
      #puts "Question2 Updated At: #{question2.updated_at}"
      expect(question1.updated_at).to be > question2.updated_at
      expect(question1.updated_at).to be > attempt.created_at
      expect(question2.updated_at).to be <= attempt.created_at
      expect(attempt.modified_questions).to eq([attempted_question1])
    end
  end

  describe "#removed_questions" do
  it "returns attempted questions whose associated question has been deleted" do
    question2.destroy
    attempt.reload
    # Debugging outputs
    #puts "Question2 Destroyed: #{question2.destroyed?}"
    #puts "Attempted Question 2's Question ID: #{attempted_question2.question_id}"

    # Expected result: attempted_question2 is returned
    expect(attempt.removed_questions).to contain_exactly(attempted_question2)

    # Verify that question1's associated attempted question is not included
    expect(attempt.removed_questions).not_to include(attempted_question1)
  end
end

  describe "#new_questions" do
    it "returns questions added to the quiz after the attempt was created" do
      new_question=quiz.questions.create!(content: "New Question?", options: ["Yes", "No"], correct_answer: "Yes", created_at: Time.now)
      new_questions = quiz.questions.where('created_at > ?', attempt.created_at)
      #debugging output
      #puts "Attempt Created At: #{attempt.created_at}"
      #puts "new_question Updated At: #{new_question.created_at}"
      expect(new_question.created_at).to be > attempt.created_at
      expect(attempt.new_questions).to eq(new_questions)
    end
  end
end

