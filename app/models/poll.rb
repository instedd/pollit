class Poll < ActiveRecord::Base
  belongs_to :owner, :class_name => User.name
  
  has_many :questions

  validate :title, :presence => true, :length => {:maximum => 64}

  include Parser
end
