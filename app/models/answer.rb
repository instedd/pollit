class Answer < ActiveRecord::Base
  belongs_to :respondent
  belongs_to :question

  validates :respondent_id, :presence => true, :uniqueness => {:scope => :question_id}
  validates :question_id, :presence => true
  validates :response, :presence => true
end
