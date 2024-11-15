class AttemptedQuestion < ApplicationRecord
  belongs_to :attempt
  belongs_to :question
  validates :question_id, uniqueness: { scope: :attempt_id }

end
