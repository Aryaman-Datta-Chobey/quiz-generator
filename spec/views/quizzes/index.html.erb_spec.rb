require 'rails_helper'

RSpec.describe "quizzes/index.html.erb", type: :view do
  include Devise::Test::ControllerHelpers
  # After updating user assc need a user to run view test
  let(:user) { User.create!(email: 'user@example.com', password: 'password') }
  let(:user1) { User.create!(email: 'user1@example.com', password: 'password') }
  before(:each) do
      user.quizzes.create!(topic: "Rspec Testing",
               difficulty: "easy",
               study_duration: 9,
               detail_level: "high",
               number_of_questions: 100,
               score: 0)
      user.quizzes.create!(topic: "Passing Rspec Tests",
               difficulty: "hard",
               study_duration: 10,
               detail_level: "high",
               number_of_questions: 100,
               score: 0)
      user1.quizzes.create!(topic: "Other user's rspec test",
               difficulty: "hard",
               study_duration: 10,
               detail_level: "high",
               number_of_questions: 100,
               score: 0)
  end
  context "when user is logged in" do
    before do
      sign_in user
      assign(:quizzes, user.quizzes)
      render
    end
    # #NOTE: Devise provides the login button so redundant to test for it
    it "displays the search bar" do
      expect(rendered).to have_selector("input[type=text]")
    end

    it "renders the user's quiz topics" do
      expect(rendered).to match(/Rspec Testing/)
      expect(rendered).to match(/Passing Rspec Tests/)
    end

    it " does NOT renders quiz topics that DON'T belong to user" do
      expect(rendered).not_to match(/Other user's rspec test/)
    end

    it "displays a button to create a new quiz" do
      expect(rendered).to have_link("Let Quizzo Fetch Your Quiz", href: new_quiz_path)
    end
  end

  context "when no user is logged in" do
    before do
      assign(:quizzes, [])
      render
    end
    # #NOTE: Devise provides the logout button so redundant to test for it
    it "displays a 'Login to get started' message" do
      expect(rendered).to match(/Log in to start exploring or creating amazing quizzes!/)
    end

    it "does not display the search bar" do
      expect(rendered).not_to have_selector("input[type=search]")
    end

    it "does not display the user's quizzes" do
      expect(rendered).not_to match(/Rspec Testing/)
      expect(rendered).not_to match(/Passing Rspec Tests/)
      expect(rendered).not_to match(/Other user's rspec test/)
    end

    it "does not display the create new quiz button" do
      expect(rendered).not_to have_link("Create New Quiz")
    end
  end
end
