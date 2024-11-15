class Question < ApplicationRecord
  belongs_to :quiz
  has_many :attempted_questions
  has_many :attempts, through: :attempted_questions
  # validates :content, :options, :correct_answer, presence: true
end
