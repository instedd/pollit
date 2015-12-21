# encoding: UTF-8
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

describe Poll do

  it "can be instantiated" do
    Poll.new.should be_an_instance_of(Poll)
  end

  it "can be saved successfully" do
    Poll.make!.should be_persisted
  end

  it "has an owner" do
    Poll.make!.owner.should_not be_nil
  end

  context "validations" do
    it "must have a title" do
      Poll.make(:title => "").should be_invalid
    end

    it "must require questions if specified" do
      Poll.make(:questions => []).should be_invalid
    end

    it "cannot have more than one question that collects respondent phone" do
      Poll.make(:questions => [
        Question.make(:text, collects_respondent: true),
        Question.make(:text, collects_respondent: true)
      ]).should be_invalid
    end
  end

  describe 'telemetry' do
    it 'updates the users lifespan when created' do
      poll = Poll.make

      Telemetry::Lifespan.should_receive(:touch_user).with(poll.owner).at_least(:once)

      poll.save
    end

    it 'updates the users lifespan when updated' do
      poll = Poll.make!

      Telemetry::Lifespan.should_receive(:touch_user).with(poll.owner)

      poll.touch
      poll.save
    end

    it 'updates the users lifespan when destroyed' do
      poll = Poll.make!

      Telemetry::Lifespan.should_receive(:touch_user).with(poll.owner).at_least(:once)

      poll.destroy
    end
  end
end
