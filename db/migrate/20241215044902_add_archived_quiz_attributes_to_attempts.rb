class AddArchivedQuizAttributesToAttempts < ActiveRecord::Migration[7.2]
  def change
    add_column :attempts, :archived_topic, :string
    add_column :attempts, :archived_difficulty, :integer
    add_column :attempts, :archived_study_duration, :integer
    add_column :attempts, :archived_detail_level, :integer
    add_column :attempts, :archived_number_of_questions, :integer
  end
end
