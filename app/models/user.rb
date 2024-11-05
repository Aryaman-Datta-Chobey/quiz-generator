class User < ApplicationRecord
    has_many :quizzes, dependent: :destroy
    has_secure_password
  
    # validates :username, presence: true, uniqueness: true
    # validates :email, presence: true, uniqueness: true
  end
