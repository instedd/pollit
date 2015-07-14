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

describe SummaryController do

  before_each_sign_in_as_new_user

  describe "get index" do

    it "should be successful" do
      p = Poll.make! :with_questions, :owner => controller.current_user
      get 'index', :poll_id => p.id
      response.should be_success
      assigns(:questions).map(&:id).should =~ p.reload.questions.map(&:id)
    end

    it "should ignore questions that collect respondents" do
      p = Poll.make! :with_collecting_respondent_question, :owner => controller.current_user
      get 'index', :poll_id => p.id
      response.should be_success
      assigns(:questions).map(&:id).should =~ p.reload.questions.reject{|q| q.collects_respondent}.map(&:id)
    end

    it "should generate CSV" do
      p = Poll.make! :with_questions, :owner => controller.current_user
      p.respondents.each do |r|
        p.questions.each do |q|
          Answer.make!(respondent: r, question: q, response: "RESPONSE")
        end
      end

      get 'index', :poll_id => p.id, :format => :csv
      response.should be_success

      csv = CSV.parse(response.body)
      header, *rows = csv
      header.should eq(['Respondent', 'Timestamp'] + p.questions.map(&:title))
      rows.length.should eq(p.respondents.length)
      rows.each do |row|
        row.length.should eq(p.questions.length+2)
        row[2..-1].should eq(["RESPONSE"] * p.questions.length)
      end
    end

    it "should generate CSV for multiple occurrences" do
      p = Poll.make! :with_questions, :owner => controller.current_user, :recurrence_rule => weekly_json(1, 2)
      p.respondents.each do |r|
        p.questions.each do |q|
          [1,2,3].each do |day|
            Answer.make!(respondent: r, question: q, response: "RESPONSE", occurrence: DateTime.new(2015,1,day))
          end
        end
      end

      get 'index', :poll_id => p.id, :format => :csv
      response.should be_success

      csv = CSV.parse(response.body)
      header, *rows = csv
      header.should eq(['Respondent', 'Timestamp', 'Occurrence'] + p.questions.map(&:title))
      rows.length.should eq(p.respondents.length * 3)
      rows.each do |row|
        row.length.should eq(p.questions.length+3)
        row[3..-1].should eq(["RESPONSE"] * p.questions.length)
      end
    end

  end

  describe "query" do
    it "should be successful" do
      p = Poll.make! :with_questions, :owner => controller.current_user
      get 'query', :poll_id => p.id, :question_id => p.questions.first.id
      response.should be_success
    end
  end

end
