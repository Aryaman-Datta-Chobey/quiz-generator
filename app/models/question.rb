class Question < ApplicationRecord
  belongs_to :quiz
  has_many :attempted_questions #, dependent: :destroy
  has_many :attempts, through: :attempted_questions
  # validates :content, :options, :correct_answer, presence: true
  after_update :notify_attempted_questions

  private

  def notify_attempted_questions
    attempted_questions.each { |aq| aq.archive_question_attributes(self,aq) }
  end
end
