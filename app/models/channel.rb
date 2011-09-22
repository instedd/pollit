class Channel < ActiveRecord::Base
  belongs_to :poll

  attr_accessor :ticket_code

  validates :ticket_code, :presence => true
  validates :name, :presence => true
  validate :poll_not_started, :message => "poll has already started"

  before_create :register_nuntium_channel
  before_destroy :delete_nuntium_channel

  private

  def poll_not_started
    poll && !poll.started?
  end

  def register_nuntium_channel
    @nuntium = Nuntium.new_from_config

    channel_info = @nuntium.create_channel({ 
      :name => name,
      :protocol => 'sms',
      :kind => 'qst_server',
      :direction => 'bidirectional',
      :ticket_code => ticket_code,
      :ticket_message => "This phone will be used for #{name}",
      :at_rules => [{
        'actions' => [{ 'property' => 'poll', 'value' => name }], 
        'matchings' => [], 
        'stop' => false 
      }],
      :restrictions => [{ 'name' => 'poll', 'value' => name }],
      :configuration => { :password => SecureRandom.base64(6) },
      :enabled => true
    })
    
    self.address = "sms://#{channel_info[:address]}"
  end

  def delete_nuntium_channel
    Nuntium.new_from_config.delete_channel(name)
  end
end
