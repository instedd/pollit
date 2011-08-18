class Respondent < ActiveRecord::Base
  has_many :answers
  belongs_to :poll
  validates_presence_of :poll

  enum_attr :pushed_status, %w(^pending succeeded failed)

  include Pusher

  def answer_for(question)
    answers.find_by_question_id question.id
  end
end
