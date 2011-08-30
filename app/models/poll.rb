class Poll < ActiveRecord::Base
  belongs_to :owner, :class_name => User.name
  
  has_many :questions, :order => "position"
  has_many :respondents

  validates :title, :presence => true, :length => {:maximum => 64}
  validates :form_url, :presence => true
  validates :post_url, :presence => true
  validates :questions, :presence => true, :if => :requires_questions
  validates :welcome_message, :presence => true
  validates :goodbye_message, :presence => true

  accepts_nested_attributes_for :questions

  MESSAGE_FROM = "sms://0"
  INVALID_REPLY_OPTIONS = "Your answer was not understood. Please answer with (%s)"
  INVALID_REPLY_TEXT = "Your answer was not understood. Please answer with non empty string"
  INVALID_REPLY_NUMERIC = "Your answer was not understood. Please answer with a number between %s and %s"

  after_initialize :default_values
  attr_accessor :requires_questions

  include Parser

  def start    
    messages = []

    respondents.each do |respondent|
      messages << {
        :from => MESSAGE_FROM,
        :to => respondent.phone,
        :body => welcome_message
      }
    end

    send_messages messages
    self.status = :started
    
    save
  end

  def accept_answer(response, respondent)
    if respondent.confirmed
      return nil if respondent.current_question_id.nil?
      
      current_question = questions.find(respondent.current_question_id)
      
      if current_question.kind_text?
        return accept_text_answer(response, respondent)
      elsif current_question.numeric?
        return accept_numeric_answer(response, respondent)
      elsif current_question.kind_options?
        return accept_options_answer(response, respondent)
      end
    else
      if response.strip.downcase == confirmation_word.strip.downcase
        respondent.confirmed = true
        current_question = questions.first
        respondent.current_question_id = current_question.id
        respondent.save!
        return current_question.description
      else
        return nil
      end
    end
  end

  def google_form_key
    return nil unless form_url || post_url
    query = URI.parse(form_url || post_url).query
    CGI::parse(query)['formkey'][0]
  end

  private
  
  def default_values
    self.confirmation_word ||= "Yes"
  end

  def accept_text_answer(response, respondent)
    question = questions.find(respondent.current_question_id)

    if response.blank?
      return INVALID_REPLY_TEXT
    else
      save_answer question, respondent, response
      return next_question_for respondent
    end
  end

  def accept_numeric_answer(response, respondent)
    question = questions.find(respondent.current_question_id)

    if(question.numeric_min..question.numeric_max).cover?(response.to_i)
      save_answer question, respondent, response
      return next_question_for respondent
    else
      return INVALID_REPLY_NUMERIC % [question.numeric_min, question.numeric_max]
    end
  end

  def accept_options_answer(response, respondent)
    question = questions.find(respondent.current_question_id)

    if question.valid_option? response
      save_answer question, respondent, response
      return next_question_for respondent
    else
      return INVALID_REPLY_OPTIONS % [question.options.join("|")]
    end
  end

  def next_question_for(respondent)
    question = questions.find(respondent.current_question_id)

    next_question = question.lower_item
    respondent.current_question_id = next_question.try(:id)
    respondent.save!

    if next_question.nil?
      respondent.push_answers
      return goodbye_message
    else
      return next_question.message
    end
  end

  private

  def send_messages(messages)
    api = Nuntium.new_from_config
    api.send_ao messages
  end

  def save_answer(question, respondent, response)
    answer = Answer.new
    answer.question = question
    answer.respondent = respondent
    answer.response = response
    answer.save
  end
end
