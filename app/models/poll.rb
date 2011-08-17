class Poll < ActiveRecord::Base
  belongs_to :owner, :class_name => User.name
  
  has_many :questions
  has_many :respondents

  validate :title, :presence => true, :length => {:maximum => 64}

  accepts_nested_attributes_for :questions

  after_initialize :default_values

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
        :body => self.welcome_message
      }
      
      respondent.confirmed = true
      respondent.save
    end

    api.send_ao messages
    self.status = :started
    save
  end

  def next_question
    ""
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
