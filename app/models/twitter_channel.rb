class TwitterChannel < Channel
  attr_accessor :token
  attr_accessor :secret
  attr_accessor :screen_name
  attr_accessor :welcome_message

  validates_presence_of :token, :secret, :screen_name, :welcome_message

  def protocol
    'twitter'
  end

  def filter_respondents(respondents)
    respondents.where('twitter is not null and length(trim(twitter)) > 0')
  end

  def respondent_address(respondent)
    respondent.twitter
  end

  private

  def register_nuntium_channel
    @nuntium = Nuntium.new_from_config
    @nuntium.create_channel({
      :name => name,
      :protocol => protocol,
      :kind => 'twitter',
      :direction => 'bidirectional',
      :restrictions => nuntium_channel_restrictions,
      :configuration => {
        :password => SecureRandom.base64(6),
        :token => token,
        :secret => secret,
        :screen_name => screen_name,
        :welcome_message => welcome_message,
        },
      :enabled => true
    })

    self.address = screen_name
  end
end
