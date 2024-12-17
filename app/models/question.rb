class Question < ApplicationRecord
  belongs_to :quiz
  has_many :attempted_questions #, dependent: :destroy
  has_many :attempts, through: :attempted_questions
  # validates :content, :options, :correct_answer, presence: true
  after_update :notify_attempted_questions
  before_destroy :archive_unarchived_attributes

  @@question_answer_instruction={
    low: {
      easy: "tests simple recall or identification of factual or conceptual information about the topic.",
      intermediate: "tests the ability to recall, understand and connect 2 or more pieces of information about the topic.",
      hard: "tests the ability to recall, understand, apply and analyze or evaluate information about the topic when given a briefly detailed example or scenario."
    },
    medium: {
      easy: "tests simple recall and identification of factual, conceptual or procedural information about the topic.",
      intermediate: "tests the ability to recall, understand and apply information about the topic to a moderately detailed example or scenario.",
      hard: "tests the ability to recall, understand, apply and analyze or evaluate information about the topic when given a moderately detailed example or scenario."
    },
    high: {
      easy: "presents a specific instance, scenario, or example related to the topic in the stem of the question and tests the ability to identify the underlying concept, rule, or principle that explains this instance.",
      intermediate: "tests the ability to recall, understand and apply information about the topic to a highly detailed example or scenario.",
      hard: "tests the ability to recall, understand, apply and analyze or evaluate information about the topic when given a highly detailed example or scenario."
    }
  }

  @@distractor_instruction = {
    low: {
      easy: "1 plausible but incorrect option (distractor).",
      intermediate: "1 or 2 plausible but incorrect options (distractors) that are similar to the correct answer.",
      hard: "1 or 2 highly plausible but subtly incorrect options (distractors) that are very similar to the correct answer."
    },
    medium: {
      easy: "3 plausible but incorrect options (distractors).",
      intermediate: "3 or 4 plausible but incorrect options (distractors) that are similar to the correct answer.",
      hard: "4 incorrect options (distractors) of which most are highly plausible (in relation to the question) but subtly incorrect (in relation to the topic info tested) and very similar to the correct answer."
    },
    high: {
      easy: "4 plausible but incorrect options (distractors).",
      intermediate: "4 or 5 plausible but incorrect options (distractors) that are similar to the correct answer.",
      hard: "5 incorrect options (distractors) of which most are highly plausible (in relation to the question) but subtly incorrect (in relation to the topic info tested) and very similar to the correct answer."
    }
  }
  def self.build_prompt(difficulty, detail_level)
    <<~INSTRUCTIONS
      1. Generate markdown for a question (and its correct answer) #{@@question_answer_instruction[detail_level.to_sym][difficulty.to_sym]}
      2. Create #{@@distractor_instruction[detail_level.to_sym][difficulty.to_sym]}, each formatted using markdown
    INSTRUCTIONS
  end
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
