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

  validates :type, :presence => true
  validates :name, :presence => true
  validate :poll_not_started, :message => _("poll has already started")

  before_validation :register_nuntium_channel, :on => :create
  before_destroy :delete_nuntium_channel

  def ready?
    true
  end

  def unprefixed_address
    return nil if not address
    address.gsub(/^#{protocol}:\/\//, '')
  end

  def last_activity
    nuntium_info['last_activity_at'] rescue nil
  end

  private

  def poll_not_started
    poll && !poll.started?
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
