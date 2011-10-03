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
  validates :owner, :presence => true
  validates :form_url, :presence => true
  validates :welcome_message, :presence => true, :length => {:maximum => 140}
  validates :post_url, :presence => true
  validates :confirmation_word, :presence => true
  validates :goodbye_message, :presence => true, :length => {:maximum => 140}
  validates :questions, :presence => true

  accepts_nested_attributes_for :questions
    
  after_initialize :default_values

  enum_attr :status, %w(^created started paused)
  
  include Parser

  def generate_unique_title!
    return unless self.title && self.owner_id
    escaped_title = self.title.gsub('%', '\%').gsub('_', '\_')
    matches = self.class.where("owner_id = ? AND title LIKE ?", owner_id, "#{escaped_title}%").select('title')
    unless matches.empty?
      index =  2
      index += 1 while matches.any?{|p| p.title.downcase == "#{title} #{index}".downcase}
      self.title = "#{title} #{index}"
    end
  end

  def start
    raise Exception.new("Cannot start question #{self.inspect}") unless can_be_started?

    messages = []
    respondents.each do |respondent|
      messages << message_to(respondent, welcome_message)
    end

    send_messages messages
    self.status = :started
    
    save
  end

  def can_be_started?
    status_created? && channel && respondents.any?
  end

  def pause
    raise Exception.new("Cannot pause unstarted question #{self.inspect}") unless self.status_started?
    self.status = :paused
    self.save
  end

  def resume
    raise Exception.new("Cannot resume unpaused question #{self.inspect}") unless self.status_paused?
    
    messages = []
    
    # Sends next questions to users with a current question and without the current_question_sent mark
    respondents_to_send_next_question = self.respondents.where(:current_question_sent => false).where('current_question_id IS NOT NULL')
    respondents_to_send_next_question.each do |r|
      messages << message_to(r, r.current_question.message)
    end

    # Must send goodbye to confirmed users without current question (finished poll) but already confirmed (to avoid sending to those unconfirmed)
    respondents_to_goodbye = self.respondents.where(:current_question_sent => false).where(:confirmed => true).where('current_question_id IS NULL')
    respondents_to_goodbye.each do |r|
      messages << message_to(r, goodbye_message)
    end

    send_messages messages

    [respondents_to_send_next_question, respondents_to_goodbye].each do |rs| 
      rs.update_all :current_question_sent => true
    end

    self.status = :started
    self.save
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

  def questions_answered
    answers.count
  end

  def answers_expected
    respondents.count * questions.count
  end

  def completion_percentage
    if answers_expected == 0
      "0%"
    else
      ((questions_answered.to_f / answers_expected.to_f)*100).round(0).to_i.to_s + "%"
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
      return self.send("accept_#{current_question.kind}_answer", response, respondent) if current_question.kind_valid?
    elsif response.strip.downcase == confirmation_word.strip.downcase
      respondent.confirmed = true
      return next_question_for respondent
    end
    nil
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
    if respondent.current_question
      next_question = respondent.current_question.lower_item
    else
      next_question = questions.first
    end

    respondent.current_question_id = next_question.try(:id)
    respondent.current_question_sent = self.status_is_not_paused?
    respondent.save!

    respondent.push_answers if next_question.nil?
    
    return next_question.try(:message) || goodbye_message unless self.status_paused?
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
    self.welcome_message ||= "Answer 'yes' if you want to participate in this poll."
    self.goodbye_message ||= "Thank you for your answers!"
  rescue
    true
  end

  def message_to(respondent, body)
    return {
      :from => MESSAGE_FROM,
      :to => respondent.phone,
      :body => body,
      :poll_id => self.id.to_s
    }
  end
end
