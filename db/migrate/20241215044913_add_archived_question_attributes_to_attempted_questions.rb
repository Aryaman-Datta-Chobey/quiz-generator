class AddArchivedQuestionAttributesToAttemptedQuestions < ActiveRecord::Migration[7.2]
  def change
    add_column :attempted_questions, :archived_content, :text
    add_column :attempted_questions, :archived_correct_answer, :string
    add_column :attempted_questions, :archived_options, :text
  end
end
