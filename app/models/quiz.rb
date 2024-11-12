class Quiz < ApplicationRecord
   #associations
   belongs_to :user
   has_many :questions, dependent: :destroy

   enum :difficulty, %i[easy intermmediate hard]
   enum :detail_level, %i[low medium high]

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
   def self.by_search_string(search)
      Quiz.where("topic LIKE ?", "%#{search}%")
   end
end
