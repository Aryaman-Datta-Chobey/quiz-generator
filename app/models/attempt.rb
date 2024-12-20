class Attempt < ApplicationRecord
  belongs_to :quiz
  has_many :attempted_questions, dependent: :destroy
  has_many :questions, through: :attempted_questions
  accepts_nested_attributes_for :attempted_questions
#Dummy Comment
  def archive_quiz_attributes(updated_quiz,archived_quiz)
    # Check if any relevant attributes have changed
    changes = {}
    %w[topic difficulty study_duration detail_level].each do |attr|
      if updated_quiz.saved_change_to_attribute?(attr) && archived_quiz.attributes["#{attr}"].nil? #only archive an attr once, do not override previous archive for consecutive updates
        changes["#{attr}"] = updated_quiz.previous_changes[attr].first
      end
    end
    # Update archived attributes if changes are detected
    update(changes) unless changes.empty?
  end

  # Get AttemptedQuestions whose question is unchanged  since this attempt was made 
  def unchanged_questions
    attempted_questions.includes(:question).where.not(question: nil).select do |attempted_question|
      attempted_question.question.updated_at <= self.created_at
    end
  end

  # Get AttemptedQuestions whose question has been changed  AFTER this attempt was made 
  def modified_questions
    attempted_questions.includes(:question).where.not(question: nil).select do |attempted_question|
      attempted_question.question.updated_at > self.created_at
    end
  end

  # Get AttemptedQuestions whose question has been DELETED   
  def removed_questions
    #attempted_questions.left_joins(:question).where(questions: { id: nil }) # prev query
    attempted_questions.includes(:question).where(question: nil)
  end

  # Get new Questions that were added to the owner quiz AFTER this attempt was made
  def new_questions
    questions = quiz.questions.where('created_at > ?', self.created_at)
    Rails.logger.debug "New Questions Debug: #{questions.pluck(:id, :created_at)}"
    questions
  end
end
