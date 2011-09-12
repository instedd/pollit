class User < ActiveRecord::Base
  has_many :polls, :foreign_key => 'owner_id'
  has_one :channel, :dependent => :destroy

  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :trackable, :validatable, :omniauthable

  attr_accessible :email, :password, :password_confirmation, 
                  :remember_me, :name, :google_token

  def current_poll
    polls.first
  end

  def register_channel(code)
    @nuntium = Nuntium.new_from_config
    
    old_channel = Channel.find_by_user_id(self.id)

    unless old_channel.nil?
      @nuntium.delete_channel old_channel.name
      old_channel.destroy 
    end
    
    channel_info = @nuntium.create_channel({ 
      :name => poll.as_channel_name, 
      :protocol => 'sms',
      :kind => 'qst_server',
      :direction => 'bidirectional',
      :ticket_code => code,
      :ticket_message => "This phone will be used for #{poll.name}",
      :at_rules => [{
        'actions' => [{ 'property' => 'poll', 'value' => poll.as_channel_name }], 
        'matchings' => [], 'stop' => false }],
      :restrictions => [{ 'name' => 'poll', 'value' => poll.as_channel_name }],
      :configuration => { :password => SecureRandom.base64(6) },
      :enabled => true
    })

    Channel.create! :name => channel_info[:name], :address => channel_info[:address]
  end
end
