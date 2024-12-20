class User < ApplicationRecord
  #associations
  has_many :quizzes , dependent: :destroy
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :omniauthable, omniauth_providers: [:google_oauth2]

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data['email']).first

    # Uncomment the section below if you want users to be created if they don't exist
    unless user
      user = User.create(email: data['email'],
                          password: Devise.friendly_token[0,20],)
    end
    user
  end
end
#Dummy comment
