class Respondent < ActiveRecord::Base

  has_many :answers
  belongs_to :poll

  validates_presence_of :poll

end
