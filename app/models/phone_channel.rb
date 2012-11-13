class PhoneChannel < Channel
  attr_accessor :ticket_code

  validates :ticket_code, :presence => true

  def protocol
    'sms'
  end

  def filter_respondents(respondents)
    respondents.where('phone is not null and length(trim(phone)) > 0')
  end

  def respondent_address(respondent)
    respondent.phone
  end

  def find_respondent(respondents, address)
    respondents.find_by_phone(address)
  end

  private

  def register_nuntium_channel
    @nuntium = Nuntium.new_from_config
    begin
      channel_info = @nuntium.create_channel({
        :name => name,
        :protocol => protocol,
        :kind => 'qst_server',
        :direction => 'bidirectional',
        :ticket_code => ticket_code,
        :ticket_message => "This phone will be used for #{name}",
        :restrictions => nuntium_channel_restrictions,
        :configuration => { :password => SecureRandom.base64(6) },
        :enabled => true
      })

      self.address = "sms://#{channel_info[:address]}"
    rescue Nuntium::Exception => e
      e.properties.each do |error|
        self.errors.add(:ticket_code, _("invalid code"))
      end
      false
    end
  end
end