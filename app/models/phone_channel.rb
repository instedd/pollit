class PhoneChannel < Channel
  attr_accessor :ticket_code

  validates :ticket_code, :presence => true

  private

  def register_nuntium_channel
    @nuntium = Nuntium.new_from_config
    begin
      channel_info = @nuntium.create_channel({ 
        :name => name,
        :protocol => 'sms',
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