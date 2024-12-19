class Quiz < ApplicationRecord
   # associations
   belongs_to :user
   has_many :questions, dependent: :destroy
   has_many :attempts, dependent: :destroy
   # has_many :attempted_questions, through: :attempts
   enum :difficulty, %i[easy intermediate hard]
   enum :detail_level, %i[low medium high]

   after_update :notify_attempts
   accepts_nested_attributes_for :questions, allow_destroy: true

   validates :topic, :difficulty, :study_duration, :detail_level, :number_of_questions, presence: true
   @@options_example={
    low: {
      easy: '["Option 1 (the distractor, (each option is also formatted using github flavoured markdown))", "Option 2"]',
      intermediate: '["Option 1 (note if question has 2 distractors this array would also have an Option 3)", "Option 2"]',
      hard: '["Option 1 (each option is also formatted using github flavoured markdown)", "Option 2", "Option 3"]'
    },
    medium: {
      easy: '["Option 1 (each option is also formatted using github flavoured markdown)", "Option 2", "Option 3"]',
      intermediate: '["Option 1 (each option is also formatted using github flavoured markdown)", "Option 2", "Option 3 (note if question has 3 distractors it would also have an Option 4)"]',
      hard: '["Option 1 (each option is also formatted using github flavoured markdown)", "Option 2", "Option 3", "Option 4"]'
    },
    high: {
      easy: '["Option 1 (each option is also formatted using github flavoured markdown)", "Option 2", "Option 3", "Option 4"]',
      intermediate: '["Option 1 (each option is also formatted using github flavoured markdown)", "Option 2", "Option 3", "Option 4 (note if question has 4 distractors it would also have an Option 5)"]',
      hard: '["Option 1 (each option is also formatted using github flavoured markdown)", "Option 2", "Option 3", "Option 4", "Option 5"]'
    }
  }

   def build_prompt
      <<~PROMPT
        You are critical component of a quiz app that recieves Quiz attributes as input and outputs JSON containing a list of a list of multiple-choice questions (MCQs) based on some instructions:
        Input (Quiz attributes):
        Topic (of the quiz): #{topic}.
        Number of Questions (in the quiz): #{number_of_questions}.
        Difficulty (of the quiz): #{difficulty}.
        Detail Level (depth of the questions): #{detail_level}.
        Instructions:
        #{Question.build_prompt(difficulty, detail_level)}
        3. The Quiz app needs you to format your output as valid JSON with this structure (invalid JSON, along with excess text before and/or after valid JSON will cause the app to crash):
        {
          "questions": [
            {
              "content": "Question text here (with any tables, lists, code chunks etc formatted using github flavoured markdown).",
              "options": #{ @@options_example[detail_level.to_sym][difficulty.to_sym]},
              "correct_answer": "Option 2"
            },
            ...
          ]
        }
        Ensure that your  JSON is valid and all questions are included.
      PROMPT
    end

   def difficulty_text
      if difficulty.nil?
         "Not specified"
      else
         difficulty.humanize
      end
   end

   def detail_level_text
      if detail_level.nil?
         "Not specified"
      else
         detail_level.humanize
      end
    end
  
    def self.by_search_string(search, user) #UPDATED to only find quizzes by topic that are owned by the user
      #user.quizzes.where("topic LIKE ?", "%#{search}%")
      Quiz.where("topic LIKE ? AND user_id = ?", "%#{search}%", user.id)
    end
    private
   def notify_attempts
      attempts.each { |attempt| attempt.archive_quiz_attributes(self,attempt) }
   end
end
