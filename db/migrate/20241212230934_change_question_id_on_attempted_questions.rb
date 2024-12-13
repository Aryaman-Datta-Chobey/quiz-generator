class ChangeQuestionIdOnAttemptedQuestions < ActiveRecord::Migration[7.2]
  def change
    remove_foreign_key :attempted_questions, :questions
    add_foreign_key :attempted_questions, :questions, on_delete: :nullify
    change_column_null :attempted_questions, :question_id, true
  end
end

