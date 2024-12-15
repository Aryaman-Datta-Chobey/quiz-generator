class AttemptedQuestion < ApplicationRecord
  belongs_to :attempt
  belongs_to :question
  validates :question_id, uniqueness: { scope: :attempt_id, allow_nil: true}

  def archive_question_attributes(updated_question,archived_question)
    # Check for changes in relevant attributes
    changes = {}
    %w[content correct_answer options].each do |attr|
      #puts("@archived_#{attr} before: #{archived_question.attributes["@archived_#{attr}"].nil?}")
      if updated_question.saved_change_to_attribute?(attr) && archived_question.attributes["#{attr}"].nil?
        changes["#{attr}"] = updated_question.previous_changes[attr].first
        #puts("@archived_#{attr} after: #{changes["archived_#{attr}"]}")
      end
    end
    # Update archived attributes if changes are detected
    update(changes) unless changes.empty?
  end
end
