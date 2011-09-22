class User < ActiveRecord::Base
  has_many :polls, :foreign_key => 'owner_id'

  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, 
                  :remember_me, :name, :google_token
end
