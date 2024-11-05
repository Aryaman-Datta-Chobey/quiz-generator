# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
user = User.create!(
  username: "SampleUser",
  email: "sampleuser@example.com",
  password: "password"
)

# Create a quiz associated with the user
quiz = Quiz.create!(
  user: user,
  topic: "Ruby on Rails Basics",
  difficulty: "Intermediate",
  study_duration: 30,
  detail_level: "Detailed",
  number_of_questions: 2,
  score: 0
)

# Create questions associated with the quiz
Question.create!(
  quiz: quiz,
  content: "What is Rails?",
  options: ["A web application framework", "A programming language", "A database", "A front-end framework"],
  correct_answer: "A web application framework"
)

Question.create!(
  quiz: quiz,
  content: "Which command is used to generate a new Rails model?",
  options: ["rails create model", "rails generate model", "rails new model", "rails model generate"],
  correct_answer: "rails generate model"
)
