class Quiz < ApplicationRecord
    has_many :questions, dependent: :destroy

     def self.by_search_string(search)
        Quiz.where("topic LIKE ?", "%#{search}%")
     end
end
