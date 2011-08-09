class Poll < ActiveRecord::Base
  belongs_to :owner, :class_name => User.name
  has_many :questions

  include Parser
end
