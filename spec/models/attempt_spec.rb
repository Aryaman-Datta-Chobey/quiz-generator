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

  describe "#unchanged_questions" do
    it "returns questions that have not been modified since the attempt was created" do
      # Debugging outputs
      #puts "Attempt Created At: #{attempt.created_at}"
      #puts "Question1 Updated At: #{question1.updated_at}"
      #puts "Question2 Updated At: #{question2.updated_at}"
      expect(question1.updated_at).to be > question2.updated_at
      expect(question1.updated_at).to be > attempt.created_at
      expect(question2.updated_at).to be <= attempt.created_at
      expect(attempt.unchanged_questions).to eq([attempted_question2])
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

  describe "#archive_quiz_attributes" do
    it "archives changes to relevant quiz attributes" do
      # Modify some attributes of the quiz
      quiz.update!(topic: "Updated Topic", difficulty: :intermediate , study_duration: 45, detail_level: :low)

      # Archive the changes
      attempt.archive_quiz_attributes(quiz)

      # Verify that the changes were archived
      expect(attempt.archived_topic).to eq("Sample Quiz")
      expect(attempt.archived_difficulty).to eq(Quiz.difficulties[:easy])  # pluralizing enum attr name lets us access the mapping
      expect(attempt.archived_study_duration).to eq(30)
      expect(attempt.archived_detail_level).to eq(Quiz.detail_levels[:low])  
    end

    it "does not archive unchanged attributes" do
      # Only modify a few attributes
      quiz.update!(study_duration: 45)

      # Archive the changes
      attempt.archive_quiz_attributes(quiz)

      # Verify only the changed attributes are archived
      expect(attempt.archived_topic).to be_nil
      expect(attempt.archived_difficulty).to be_nil
      expect(attempt.archived_study_duration).to eq(30)  # This attribute should have been archived
      expect(attempt.archived_detail_level).to be_nil
    end

    it "does not update when no attributes have changed" do
      # No changes to quiz attributes
      expect { attempt.archive_quiz_attributes(quiz) }.not_to change { attempt.reload.attributes }
    end
  end
end

