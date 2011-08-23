class Poll < ActiveRecord::Base
  belongs_to :owner, :class_name => User.name
  
  has_many :questions, :order => "position"
  has_many :respondents

  validates :title, :presence => true, :length => {:maximum => 64}
  validates :form_url, :presence => true
  validates :post_url, :presence => true
  validates :questions, :presence => true, :if => :requires_questions

  accepts_nested_attributes_for :questions

  INVALID_REPLY_OPTIONS = "Your answer was not understood. Please answer with (%s)"
  INVALID_REPLY_TEXT = "Your answer was not understood. Please answer with non empty string"
  INVALID_REPLY_NUMERIC = "Your answer was not understood. Please answer with a number between %s and %s"

  after_initialize :default_values
  attr_accessor :requires_questions

  include Parser

  def start
    service_url = Pollit::Application.config.nuntium_service_url
    account_name = Pollit::Application.config.nuntium_account_name
    app_name = Pollit::Application.config.nuntium_app_name
    app_password = Pollit::Application.config.nuntium_app_password

    api = Nuntium.new service_url, account_name, app_name, app_password
    
    messages = []

    respondents.each do |respondent|
      messages << {
        :from => Pollit::Application.config.nuntium_message_from,
        :to => respondent.phone,
        :body => welcome_message
      }
    end

    api.send_ao messages
    self.status = :started
    save
  end

  def accept_answer(response, respondent)
    if respondent.confirmed
      return nil if respondent.current_question_id.nil?
      
      current_question = questions.find(respondent.current_question_id)
      
      if current_question.kind_text?
        accept_text_answer(response, respondent)
      elsif current_question.numeric?
        accept_numeric_answer(response, respondent)
      elsif current_question.kind_options?
        accept_options_answer(response, respondent)
      end
    else
      if response.strip.downcase == confirmation_word.strip.downcase
        respondent.confirmed = true
        current_question = questions.first
        respondent.current_question_id = current_question
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
    if response.blank?
      return INVALID_REPLY_TEXT
    else
      return next_question_for respondent
    end
  end

  def accept_numeric_answer(response, respondent)
    question = questions.find(respondent.current_question_id)

    if(question.numeric_min..question.numeric_max).cover?(response)
      return next_question_for respondent
    else
      return INVALID_REPLY_NUMERIC % [question.numeric_min, question.numeric_max]
    end
  end

  def accept_options_answer(response, respondent)
    question = questions.find(respondent.current_question_id)

    if question.options.include?(response)
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
      return goodbye_message
    else
      return next_question.message
    end
  end
end
