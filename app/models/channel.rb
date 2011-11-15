class Channel < ActiveRecord::Base
  belongs_to :poll

  attr_accessor :ticket_code

  validates :ticket_code, :presence => true
  validates :name, :presence => true
  validate :poll_not_started, :message => _("poll has already started")

  before_validation :register_nuntium_channel, :on => :create
  before_destroy :delete_nuntium_channel

  def unprefixed_address
    return nil if not address
    address.gsub(/^sms:\/\//, '')
  end

  def last_activity
    nuntium_info['last_activity_at'] rescue nil
  end

  private

  def poll_not_started
    poll && !poll.started?
  end

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

  def nuntium_channel_restrictions
    values = if poll.nil? then [''] else [poll.id.to_s, ''] end
    [{ 'name' => 'poll_id', 'value' => values }]
  end

  def delete_nuntium_channel
    begin
      Nuntium.new_from_config.delete_channel(name)
    rescue Nuntium::Exception => e
      logger.warn("Error deleting nuntium channel #{name}: #{e}")
    end
  end

  def nuntium_info
    @nuntium_info ||= Nuntium.new_from_config.channel(name)
  end
end
