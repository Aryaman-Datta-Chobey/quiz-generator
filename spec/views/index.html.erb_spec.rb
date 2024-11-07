require 'rails_helper'

RSpec.describe "quizzes/index.html.erb", type: :view do
  before(:each) do
    assign(:quizzes, [
      Quiz.new(topic: "Rspec Testing",
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
               score: 0)
    ])
  end

  it "renders the quiz topics" do
    render
    expect(rendered).to match(/Rspec Testing/)
    expect(rendered).to match(/Passing Rspec Tests/)
  end
end

RSpec.describe "Quizzes", type: :system do
  before do
    driven_by(:rack_test)
  end

    it 'filters quizzes by search string' do
      Quiz.create!(topic: "Rspec Testing", difficulty: "easy", study_duration: 9, detail_level: "high", number_of_questions: 100, score: 0)
      Quiz.create!(topic: "Passing Rspec Tests", difficulty: "hard", study_duration: 10, detail_level: "high", number_of_questions: 100, score: 0)

      visit quizzes_path
      fill_in 'query', with: 'Passing Rspec'
      click_button 'Find Quiz'

    expect(page).to have_content("Passing Rspec Tests")
    expect(page).not_to have_content("Rspec Testing")
  end
end
