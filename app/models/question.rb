class Question < ApplicationRecord
  belongs_to :quiz
  has_many :attempted_questions #, dependent: :destroy
  has_many :attempts, through: :attempted_questions
  # validates :content, :options, :correct_answer, presence: true
  after_update :notify_attempted_questions
  before_destroy :archive_unarchived_attributes
  private

  def notify_attempted_questions
    attempted_questions.each { |aq| aq.archive_question_attributes(self,aq) }
  end

  def archive_unarchived_attributes
    attempted_questions.each do |aq|
      aq.archive_question_attributes_before_destruction(self, aq)
    end
  end
end
