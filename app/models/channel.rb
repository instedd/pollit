# Copyright (C) 2011-2012, InSTEDD
#
# This file is part of Pollit.
#
# Pollit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Pollit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Pollit.  If not, see <http://www.gnu.org/licenses/>.

class Channel < ActiveRecord::Base
  belongs_to :poll
  belongs_to :owner, :class_name => User.name

  attr_accessor :ticket_code

  validates :ticket_code, :presence => true
  validates :name, :presence => true
  validate :poll_not_started, :message => _("poll has already started")

  before_validation :register_nuntium_channel, :on => :create
  before_destroy :delete_nuntium_channel

  after_save :touch_user_lifespan
  after_destroy :touch_user_lifespan

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

  def touch_user_lifespan
    Telemetry::Lifespan.touch_user(self.poll.try(:owner))
  end
end
