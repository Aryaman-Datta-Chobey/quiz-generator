class AttemptedQuestion < ApplicationRecord
  belongs_to :attempt
  belongs_to :question
  validates :question_id, uniqueness: { scope: :attempt_id, allow_nil: true}
#Dummy comment
  def archive_question_attributes(updated_question,archived_question)
    # Check for changes in relevant attributes
    changes = {}
    %w[content correct_answer options].each do |attr| #archive a question attr into attempted_question attr only once: subsequent updates of question should overided the first archived value
      if updated_question.saved_change_to_attribute?(attr) && archived_question.attributes["#{attr}"].nil?
        changes["#{attr}"] = updated_question.previous_changes[attr].first
      end
    end
    # Update archived attributes if changes are detected
    update(changes) unless changes.empty?
  end

  # Archiving question attributes to AttemptedQuestion before question is destroyed
  def archive_question_attributes_before_destruction(updated_question, archived_question)
    # Only archive if the attribute has not already been archived (i.e., nil value)
    changes = {}
    %w[content correct_answer options].each do |attr|
      if archived_question.attributes["#{attr}"].nil?
        # Archive the current attribute value to AttemptedQuestion before destruction
        changes["#{attr}"] = updated_question.attributes[attr]
      end
    end

    # Update only if changes are detected
    update(changes) unless changes.empty?
  end
end
