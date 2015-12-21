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

describe User do
  it "can be instantiated" do
    User.new.should be_an_instance_of(User)
  end

  it "can be saved successfully" do
    User.make!.should be_persisted
  end

  it "has many polls" do
    user = User.make!
    3.times do Poll.make!(:owner => user) end
    user.reload.should have(3).polls
  end

  describe 'telemetry' do
    it 'updates its lifespan when created' do
      user = User.make

      Telemetry::Lifespan.should_receive(:touch_user).with(user)

      user.save
    end

    it 'updates its lifespan when updated' do
      user = User.make!

      Telemetry::Lifespan.should_receive(:touch_user).with(user)

      user.touch
      user.save
    end

    it 'updates its lifespan when destroyed' do
      user = User.make!

      Telemetry::Lifespan.should_receive(:touch_user).with(user)

      user.destroy
    end
  end
  
end
