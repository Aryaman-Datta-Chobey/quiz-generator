class AddArchivedQuizAttributesToAttempts < ActiveRecord::Migration[7.2]
  def change
    add_column :attempts, :topic, :string
    add_column :attempts, :difficulty, :integer
    add_column :attempts, :study_duration, :integer
    add_column :attempts, :detail_level, :integer
    add_column :attempts, :number_of_questions, :integer
  end
end
