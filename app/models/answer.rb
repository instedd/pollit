class Answer < ActiveRecord::Base

  belongs_to :respondent
  belongs_to :question

  validates_presence_of :respondent
  validates_presence_of :question

  validates_uniqueness_of :respondent_id, :scope => [:question_id]

end
