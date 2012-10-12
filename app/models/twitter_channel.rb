class TwitterChannel < Channel
  attr_accessor :token
  attr_accessor :secret
  attr_accessor :screen_name
  attr_accessor :welcome_message

  validates_presence_of :token, :secret, :screen_name, :welcome_message

  private

  def register_nuntium_channel
    @nuntium = Nuntium.new_from_config
    @nuntium.create_channel({ 
      :name => name,
      :protocol => 'twitter',
      :kind => 'twitter',
      :direction => 'bidirectional',
      :token => token,
      :secret => secret,
      :screen_name => screen_name,
      :welcome_message => welcome_message,
      :restrictions => nuntium_channel_restrictions,
      :configuration => { :password => SecureRandom.base64(6) },
      :enabled => true
    })
  
    self.address = screen_name
  end
end
