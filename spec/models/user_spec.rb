require 'rails_helper'

RSpec.describe User, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
require 'rails_helper'

RSpec.describe User, type: :model do
  describe "from_omniauth callback" do

    it "should handle data from google for an existing user" do
      User.create!(email: 'user@colgate.edu', password: 'nothing')
      token = double('token')
      data = { email: 'user@colgate.edu' } 
      expect(token).to receive('info').and_return(data)
      expect(User.from_omniauth(token)).to be_an_instance_of(User)
    end

    it "should create a new user if one doesn't exist" do
      token = double('token')
      data = { email: 'user@colgate.edu' } 
      expect(token).to receive('info').and_return(data)
      expect(User.from_omniauth(token)).to be_an_instance_of(User)
    end
  end
end