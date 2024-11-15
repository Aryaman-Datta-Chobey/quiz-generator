class CreateAttemptedQuestions < ActiveRecord::Migration[7.2]
  def change
    create_table :attempted_questions do |t|
      t.references :attempt, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.integer :index
      t.string :user_answer
      t.boolean :correct

      t.timestamps
    end
  end
end
