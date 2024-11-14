class AddUserReferenceToQuiz < ActiveRecord::Migration[7.2]
  def change
    change_table :quizzes do |t| 
      t.references :user, foreign_key: true
      # can also do the following, but references is better
      # t.integer 'user_id'
    end 

  end
end
