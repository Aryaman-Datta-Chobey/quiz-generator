class Quiz < ApplicationRecord
  belongs_to :user
  has_many :questions, dependent: :destroy

  # validates :topic, :difficulty, :study_duration, :detail_level, :number_of_questions, presence: true
end
