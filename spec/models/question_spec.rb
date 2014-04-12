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

describe Question do
  it "can be instantiated" do
    Question.new.should be_an_instance_of(Question)
  end

  it "can be saved successfully" do
    Question.make!.should be_persisted
  end

  it "can be saved successfully with options" do
    question = Question.make!(:options)
    question.should be_persisted
    question.options.should_not be_empty
  end

  it "has many answers" do
    question = Question.make!(:answers => [Answer.make!(:response => 'foo'), Answer.make!(:response => 'bar')])
    question.reload.should have(2).answers
  end

  context "as message" do
    it "can be set to message being text" do
      Question.make!(:text, :title => "A question?").message.should\
        eq("A question?")
    end

    it "can be set to message being options" do
      Question.make!(:options, :title => "An options question?", :options => %w(foo bar baz)).message.should\
        eq("An options question? a-foo b-bar c-baz")
    end

    it "can be set to message being numeric" do
      Question.make!(:numeric, :title => "A numeric question?", :numeric_min => 1, :numeric_max => 4).message.should\
        eq("A numeric question? 1-4")
    end
  end

  context "validations" do
    it "cannot save question without title" do
      Question.make(:text, :title => "").should be_invalid
    end

    it "cannot save options question without options" do
      Question.make(:options, :title => "An options question?", :options => []).should be_invalid
    end

    it "cannot save long text question" do
      Question.make(:text, :title => "X" * 141).should be_invalid
    end

    it "cannot save long options question" do
      Question.make(:options, :title => "An options question?", :options => ["foo"] * 40).should be_invalid
    end
  end

end
