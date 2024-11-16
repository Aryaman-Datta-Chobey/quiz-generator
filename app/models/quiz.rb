class Quiz < ApplicationRecord
   # associations
   belongs_to :user
   has_many :questions, dependent: :destroy
   has_many :attempts, dependent: :destroy
   # has_many :attempted_questions, through: :attempts
   enum :difficulty, %i[easy intermediate hard]
   enum :detail_level, %i[low medium high]

   accepts_nested_attributes_for :questions, allow_destroy: true


   validates :topic, :difficulty, :study_duration, :detail_level, :number_of_questions, presence: true

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

   def self.by_search_string(search, user) # UPDATED to only find quizzes by topic that are owned by the user
      user.quizzes.where("topic LIKE ?", "%#{search}%")
   end
end
