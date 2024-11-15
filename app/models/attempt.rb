class Attempt < ApplicationRecord
  belongs_to :quiz
  has_many :attempted_questions
  has_many :questions, through: :attempted_questions
  accepts_nested_attributes_for :attempted_questions
end
