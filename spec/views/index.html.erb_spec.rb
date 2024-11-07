require 'rails_helper'

RSpec.describe "quizzes/index.html.erb", type: :view do
  it "should render a quiz" do
    assign(:quizzes, [ Quiz.new(topic: "Rspec Testing",
                             difficulty: "easy",
                             study_duration: 9,
                             detail_level: "high",
                             number_of_questions: 100,
                             score: 0),
                     Quiz.new(topic: "Passing Rspec Tests",
                             difficulty: "hard",
                             study_duration: 10,
                             detail_level: "high",
                             number_of_questions: 100,
                             score: 0) ])
    render
    expect(rendered).to match(/Rspec Testing/)
    expect(rendered).to match(/Passing Rspec Tests/)
  end
end
