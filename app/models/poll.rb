class Poll < ActiveRecord::Base
  belongs_to :owner, :class_name => User.name
  
  has_many :questions
  has_many :respondants

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
    
    message = {
      :from => "sms://0",
      :to => "sms://5678",
      :body => "Hello Nuntium!"
    }
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
