class Poll < ActiveRecord::Base
  belongs_to :owner, :class_name => User.name
  
  has_many :questions, :order => "position"
  has_many :respondents

  validates :title, :presence => true, :length => {:maximum => 64}
  validates :form_url, :presence => true
  validates :post_url, :presence => true
  validates :questions, :presence => true, :if => :requires_questions

  accepts_nested_attributes_for :questions

  INVALID_REPLY = "Your answer was not understood. Please answer with (%s)"

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

    response = api.send_ao messages
    self.status = :started
    save

    p response
  end

  def accept_answer(response, respondent)
    if respondent.confirmed
      current_question_id = respondent.current_question_id

      return nil if current_question_id.nil?

      options = questions.find(current_question_id).options

      if options.include?(answer)
        next_question = questions.where(:id => current_question_id).lower_item
        respondent.current_question_id = next_question.try(:id)
        respondent.save!

        if (next_question.nil?)
          return goodbye_message
        else
          return next_question.description
        end
      else
        return INVALID_REPLY % [options.join("|")]
      end
    else
      if response.strip.downcase == poll.confirmation_word.strip.downcase
        respondent.confirmed = true
        respondent.current_question_id = questions.first
        respondent.save!
        return welcome_message
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

end
