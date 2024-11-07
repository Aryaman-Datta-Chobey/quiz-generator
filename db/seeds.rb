# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
quiz = Quiz.create!(
  topic: "Ruby on Rails Basics",
  difficulty: :easy,
  study_duration: 30,
  detail_level: "high",
  number_of_questions: 2,
  score: 0
)


# Create questions associated with the quiz
Question.create!(
  quiz: quiz,
  content: "What is Rails?",
  options: [ "A web application framework", "A programming language", "A database", "A front-end framework" ],
  correct_answer: "A web application framework"
)
Question.create!(
  quiz: quiz,
  content: "Which command is used to generate a new Rails model?",
  options: [ "rails create model", "rails generate model", "rails new model", "rails model generate" ],
  correct_answer: "rails generate model"
)


quiz2 = Quiz.create!(
  topic: "RSpec Basics ",
  difficulty: :easy,
  study_duration: 45,
  detail_level: "low",
  number_of_questions: 3,
  score: 0
)

# Create questions associated with the quiz
Question.create!(
  quiz: quiz2,
  content: "What is Rspec?",
  options: [ "A computer domain-specific language testing tool written in the programming language Ruby to test Ruby code. It is a behavior-driven development framework which is extensively used in production applications.", "A way to test something", "I dont know" ],
  correct_answer: "A computer domain-specific language testing tool written in the programming language Ruby to test Ruby code. It is a behavior-driven development framework which is extensively used in production applications."
)
Question.create!(
  quiz: quiz2,
  content: "What color tells us there is a failing test",
  options: [ "Green", "Red", "Yellow" ],
  correct_answer: "Red"
)
Question.create!(
  quiz: quiz2,
  content: "What vegtable goes well with RSpec",
  options: [ "Cucumber", "Zucchini", "Apple" ],
  correct_answer: "Cucumber"
)
