class Quiz < ApplicationRecord
   # associations
   belongs_to :user
   has_many :questions, dependent: :destroy
   has_many :attempts, dependent: :destroy
   # has_many :attempted_questions, through: :attempts
   enum :difficulty, %i[easy intermediate hard]
   enum :detail_level, %i[low medium high]
#Dummy comment
   after_update :notify_attempts
   accepts_nested_attributes_for :questions, allow_destroy: true


   validates :topic, :difficulty, :study_duration, :detail_level, :number_of_questions, presence: true

   def build_prompt
      <<~PROMPT
        Generate a multiple-choice questions (MCQs) based quiz using the following inputs:
        Topic (of the quiz): #{topic}.
        Number of Questions (in the quiz): #{number_of_questions}.
        Difficulty (of the quiz): #{difficulty}.
        Detail Level (depth of the questions): #{detail_level}.
        Instructions:
        For each question, generate a question and its correct answer (appropriate to the input difficulty and detail level).
        2. Create three plausible but incorrect options (distractors) for each question.
        3. Format the output as valid JSON with this structure:
        {
          "questions": [
            {
              "content": "Question text here",
              "options": ["Option 1", "Option 2", "Option 3", "Option 4"],
              "correct_answer": "Option 2"
            },
            ...
          ]
        }
        Ensure the JSON includes all questions.
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
