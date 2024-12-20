# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
#Seeding users
user1=User.create!(email: 'aryaman@colgate.edu', password: 'colgate13')
user2=User.create!(email: 'thanh@colgate.edu', password: 'colgate13')
user3=User.create!(email: 'stefano@colgate.edu', password: 'colgate13')

# 2 identical quizzes are seeded for each of the 3 users above using quiz templates
users = [user1, user2, user3]
quiz_templates = [
  {
    topic: "Ruby on Rails Basics",
    difficulty: :easy,
    study_duration: 30,
    detail_level: :high,
    number_of_questions: 2,
    questions: [
      {
        content: "What is Rails?",
        options: ["A web application framework", "A programming language", "A database", "A front-end framework"],
        correct_answer: "A web application framework"
      },
      {
        content: "Which command is used to generate a new Rails model?",
        options: ["rails create model", "rails generate model", "rails new model", "rails model generate"],
        correct_answer: "rails generate model"
      }
    ]
  },
  {
    topic: "RSpec Basics",
    difficulty: :easy,
    study_duration: 45,
    detail_level: :low,
    number_of_questions: 3,
    questions: [
      {
        content: "What is RSpec?",
        options: ["A computer domain-specific language testing tool written in Ruby to test Ruby code. It is a behavior-driven development framework extensively used in production applications.", "A way to test something", "I don't know"],
        correct_answer: "A computer domain-specific language testing tool written in Ruby to test Ruby code. It is a behavior-driven development framework extensively used in production applications."
      },
      {
        content: "What color tells us there is a failing test",
        options: ["Green", "Red", "Yellow"],
        correct_answer: "Red"
      },
      {
        content: "What vegetable goes well with RSpec",
        options: ["Cucumber", "Zucchini", "Apple"],
        correct_answer: "Cucumber"
      }
    ]
  }
]

users.each do |user|
  quiz_templates.each do |quiz_data|
    # Create quiz for the user
    quiz = user.quizzes.create!(
      topic: quiz_data[:topic],
      difficulty: quiz_data[:difficulty],
      study_duration: quiz_data[:study_duration],
      detail_level: quiz_data[:detail_level],
      number_of_questions: quiz_data[:number_of_questions],
      score: 0
    )

    # Create associated questions for the quiz
    quiz_data[:questions].each do |question_data|
      quiz.questions.create!(
        content: question_data[:content],
        options: question_data[:options],
        correct_answer: question_data[:correct_answer]
      )
    end
  end
end