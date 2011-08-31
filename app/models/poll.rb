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

  def completion_percentage
    answers_count = Answer.includes(:respondent => :poll).where("polls.id = ?", id).count
    if (questions.count == 0 || respondents.count == 0)
      "0%"
    else
      (answers_count.to_f / (respondents.count.to_f * questions.count.to_f) * 100).to_i.to_s + "%"
    end
  end

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
      INVALID_REPLY_TEXT
    else
      Answer.create :question => question, :respondent => respondent, :response => response
      next_question_for respondent
    end
  end

  def accept_numeric_answer(response, respondent)
    question = questions.find(respondent.current_question_id)

    if(question.numeric_min..question.numeric_max).cover?(response.to_i)
      Answer.create :question => question, :respondent => respondent, :response => response.to_i
      next_question_for respondent
    else
      INVALID_REPLY_NUMERIC % [question.numeric_min, question.numeric_max]
    end
  end

  def accept_options_answer(response, respondent)
    question = questions.find(respondent.current_question_id)
    option = question.option_for(response)

    if option.nil?
      INVALID_REPLY_OPTIONS % [question.options.join("|")]
    else
      Answer.create :question => question, :respondent => respondent, :response => option
      next_question_for respondent
    end
  end

  def next_question_for(respondent)
    question = questions.find(respondent.current_question_id)

    next_question = question.lower_item
    respondent.current_question_id = next_question.try(:id)
    respondent.save!

    if next_question.nil?
      respondent.push_answers
      goodbye_message
    else
      next_question.message
    end
  end

  private

  def send_messages(messages)
    Nuntium.new_from_config.send_ao messages
  end
end
