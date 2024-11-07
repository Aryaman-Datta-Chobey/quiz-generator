require 'rails_helper'



RSpec.describe "Index Route", type: :view do
  before do
    driven_by(:rack_test)
  end

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
    expect(page.text).to match(/Rspec Testing/)
    expect(page.text).to match(/Passing Rspec Tests/)
    expect(page.text).to match(/Rspec Testing.*Passing Rspec Tests/mi)
  end

  it 'should filter quizzes by search string' do
      visit quizzes_path
      fill_in 'query', with: 'Rails'
      click_button 'Find Quiz'
      expect(page.text).to match(/Rspec Testing/i)
      expect(page.text).not_to match(/Passing Rspec Tests/i)
  end
end
