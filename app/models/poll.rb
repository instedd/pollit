class Poll < ActiveRecord::Base
  MESSAGE_FROM = "sms://0"
  INVALID_REPLY_OPTIONS = "Your answer was not understood. Please answer with (%s)"
  INVALID_REPLY_TEXT = "Your answer was not understood. Please answer with non empty string"
  INVALID_REPLY_NUMERIC = "Your answer was not understood. Please answer with a number between %s and %s"

  belongs_to :owner, :class_name => User.name
  has_many :questions, :order => "position"
  has_many :respondents, :dependent => :destroy
  has_many :answers, :through => :respondents
  has_one :channel, :dependent => :destroy

  validates :title, :presence => true, :length => {:maximum => 64}, :uniqueness => {:scope => :owner_id}
  validates :description, :presence => true
  validates :owner, :presence => true
  validates :form_url, :presence => true
  validates :welcome_message, :presence => true, :length => {:maximum => 140}
  validates :post_url, :presence => true
  validates :confirmation_word, :presence => true
  validates :goodbye_message, :presence => true, :length => {:maximum => 140}
  validates :questions, :presence => true

  accepts_nested_attributes_for :questions
    
  after_initialize :default_values
  
  include Parser

  def start
    return false unless can_be_started?

    messages = []
    respondents.each do |respondent|
      messages << {
        :from => MESSAGE_FROM,
        :to => respondent.phone,
        :body => welcome_message,
        :poll_id => self.id.to_s
      }
    end

    send_messages messages
    self.status = :started
    
    save
  end

  def can_be_started?
    (!started?) && channel && respondents.any?
  end

  def started?
    self.status.to_s == "started"
  end

  def as_channel_name
    "#{title}-#{id}".parameterize
  end

  def register_channel(ticket_code)
    Channel.create({
      :ticket_code => ticket_code,
      :name => as_channel_name,
      :poll_id => id
    })
  end

  def completion_percentage
    if (questions.count == 0 || respondents.count == 0)
      "0%"
    else
      (answers.count.to_f / (respondents.count.to_f * questions.count.to_f) * 100).to_i.to_s + "%"
    end
  end

  def google_form_key
    return nil unless form_url || post_url
    query = URI.parse(form_url || post_url).query
    CGI::parse(query)['formkey'][0]
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
        return current_question.message
      else
        return nil
      end
    end
  end
  
  private

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

  def send_messages(messages)
    begin
      Nuntium.new_from_config.send_ao messages
    rescue MultiJson::DecodeError
      # HACK until nuntium ruby api is fixed
    end
  end

  def default_values
    self.confirmation_word ||= "Yes"
  end
end
