class Respondent < ActiveRecord::Base
  has_many :answers, :dependent => :destroy
  belongs_to :current_question, :class_name => Question.name
  belongs_to :poll

  validates :phone, :presence => true, :uniqueness => { :scope => :poll_id }

  enum_attr :pushed_status, %w(^pending succeeded failed)

  include Pusher

  def answer_for(question)
    answers.find_by_question_id question.id
  end

  def unprefixed_phone
    return nil if not phone
    phone.gsub(/^sms:\/\//, '')
  end
end
