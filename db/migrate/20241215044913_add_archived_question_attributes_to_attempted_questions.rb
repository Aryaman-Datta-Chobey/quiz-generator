class AddArchivedQuestionAttributesToAttemptedQuestions < ActiveRecord::Migration[7.2]
  def change
    add_column :attempted_questions, :content, :text
    add_column :attempted_questions, :correct_answer, :string
    add_column :attempted_questions, :options, :text
  end
end
