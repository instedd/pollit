class Poll < ActiveRecord::Base
  belongs_to :owner, :class_name => User.name
  
  has_many :questions
  has_many :respondents

  validate :title, :presence => true, :length => {:maximum => 64}

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
        :body => "Hello Nuntium!"
      }
    end

    api.send_ao messages
    self.status = :started
  end

  include Parser
end
