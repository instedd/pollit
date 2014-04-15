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

describe Answer do
  it "can be instantiated" do
    Answer.new.should be_an_instance_of(Answer)
  end

  it "can be saved successfully" do
    Answer.make!.should be_persisted
  end

  it "must be unique for question and respondent and ocurrence" do
    respondent = Respondent.make!
    question = Question.make!

    Answer.make!(:respondent => respondent, :question => question).should be_persisted
    Answer.make(:respondent => respondent, :question => question).should be_invalid
  end

  it "must be unique for question and respondent and ocurrence" do
    respondent = Respondent.make!
    question = Question.make!
    occurrence = Time.now

    Answer.make!(:respondent => respondent, :question => question, :occurrence => occurrence).should be_persisted
    Answer.make(:respondent => respondent, :question => question, :occurrence => occurrence).should be_invalid
    Answer.make(:respondent => respondent, :question => question, :occurrence => occurrence + 1.day).should be_valid
  end
end
