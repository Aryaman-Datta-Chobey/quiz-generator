require 'rails_helper'
RSpec.describe "Badids", type: :system do
  before do
    driven_by(:rack_test)
  end
  describe "Bad id #index (sad_path)" do
    it 'should tell us that we are looking for an Invalid Quiz' do
      visit quiz_path(1000)
      expect(page.text).to match(/Invalid quiz ID/i)
    end
  end
end