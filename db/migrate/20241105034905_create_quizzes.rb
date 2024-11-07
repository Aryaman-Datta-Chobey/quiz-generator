class CreateQuizzes < ActiveRecord::Migration[7.2]
  def change
    create_table :quizzes do |t|
      t.string :topic
      t.integer :difficulty
      t.integer :study_duration
      t.integer :detail_level
      t.integer :number_of_questions
      t.integer :score

      t.timestamps
    end
  end
end
