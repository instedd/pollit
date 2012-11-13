class TwitterChannel < Channel
  attr_accessor :token
  attr_accessor :secret
  attr_accessor :screen_name
  attr_accessor :welcome_message

  def protocol
    'twitter'
  end

  def ready?
    address.present?
  end

  def filter_respondents(respondents)
    respondents.where('twitter is not null and length(trim(twitter)) > 0')
  end

  def respondent_address(respondent)
    respondent.twitter
  end

  def find_respondent(respondents, address)
    respondents.find_by_twitter(address)
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
        :welcome_message => welcome_message,
        },
      :enabled => true
    })
  end
end
