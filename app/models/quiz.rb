class Quiz < ApplicationRecord
   has_many :questions, dependent: :destroy

   enum :difficulty, %i[easy intermmediate hard]
   enum :detail_level, %i[low medium high]

   validates :topic, :difficulty, :study_duration, :detail_level, :number_of_questions, presence: true
   def self.by_search_string(search)
      Quiz.where("topic LIKE ?", "%#{search}%")
   end
end
