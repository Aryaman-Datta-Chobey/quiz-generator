class CreateQuizzes < ActiveRecord::Migration[7.2]
  def change
    create_table :quizzes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :topic
      t.string :difficulty
      t.integer :study_duration
      t.string :detail_level
      t.integer :number_of_questions
      t.integer :score

      t.timestamps
    end
  end
end
