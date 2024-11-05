class Question < ApplicationRecord
  belongs_to :quiz
  # validates :content, :options, :correct_answer, presence: true
end
