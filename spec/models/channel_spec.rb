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

require 'spec_helper'

describe Channel do
  describe 'telemetry' do
    let(:poll) { Poll.make! }

    it 'updates the users lifespan when created' do
      channel = Channel.make poll: poll

      Telemetry::Lifespan.should_receive(:touch_user).with(poll.owner)

      channel.save
    end

    it 'updates the users lifespan when updated' do
      channel = Channel.make! poll: poll

      Telemetry::Lifespan.should_receive(:touch_user).with(poll.owner)

      channel.touch
      channel.save
    end

    it 'updates the users lifespan when destroyed' do
      channel = Channel.make! poll: poll

      Telemetry::Lifespan.should_receive(:touch_user).with(poll.owner)

      channel.destroy
    end
  end
end
