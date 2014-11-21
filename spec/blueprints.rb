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

require 'machinist/active_record'
require 'faker'

# module defined to update machinist version
module Sham
  def self.title        ; Faker::Lorem.words.join(' ') ; end
  def self.question     ; "#{Faker::Lorem.words.join(' ')}?" ; end
  def self.response     ; Faker::Lorem.words.join(' ') ; end
  def self.description  ; Faker::Lorem.paragraph.first(100) ; end
  def self.email        ; Faker::Internet.email ; end
  def self.url          ; "http://#{Faker::Internet.domain_name}" ; end
  def self.password     ; rand(36**8).to_s(36) ; end
  def self.name         ; Faker::Lorem.words.first ; end
  def self.phone        ; "sms://#{rand(10000)}" ; end
  def self.ticket_code  ; rand(9999) ; end
end

User.blueprint do
  email {Sham.email}
  name {Sham.name}
  password {Sham.password}
  password_confirmation {password}
  confirmed_at {DateTime.now}
  confirmation_sent_at {DateTime.now}
end

Channel.blueprint do
  ticket_code {Sham.ticket_code}
  name {Sham.name}
end

Poll.blueprint do
  title           {Sham.title}
  description     {Sham.description}
  form_url        {Sham.url}
  post_url        {Sham.url}
  owner           {User.make}
  channel         { Channel.make }
  questions(1)
end

Poll.blueprint(:with_questions) do
  channel           {Channel.make}
  title             {Sham.title}
  description       {Sham.description}
  form_url          {Sham.url}
  post_url          {Sham.url}
  owner             { User.make! }
  respondents(5)
  questions     {[
    Question.make(:field_name => 'entry.0.single', :position => 1),
    Question.make(:options, :options => %w(foo bar baz), :field_name => 'entry.1.single', :position => 2),
    Question.make(:options, :options => %w(oof rab zab), :field_name => 'entry.2.group', :position => 3),
    Question.make(:numeric, :numeric_min => 1, :numeric_max => 10, :field_name => 'entry.3.group', :position => 4)]}
end

Poll.blueprint(:with_text_questions) do
  channel           {Channel.make}
  title             {Sham.title}
  description       {Sham.description}
  form_url          {Sham.url}
  post_url          {Sham.url}
  owner             {User.make}
  respondents(5)
  questions         {[
    Question.make(:field_name => 'entry.0.single', :position => 1),
    Question.make(:field_name => 'entry.1.single', :position => 2),
    Question.make(:field_name => 'entry.2.single', :position => 3)]}
end

Poll.blueprint(:with_collecting_respondent_question) do
  channel           {Channel.make}
  title             {Sham.title}
  description       {Sham.description}
  form_url          {Sham.url}
  post_url          {Sham.url}
  owner             {User.make}
  respondents(5)
  questions         {[
    Question.make(:field_name => 'entry.0.single', :position => 1, :title => "Question 1?"),
    Question.make(:field_name => 'entry.1.single', :position => 2, :title => "Question 2?", :collects_respondent => true),
    Question.make(:field_name => 'entry.2.single', :position => 3, :title => "Question 3?")]}
end

Poll.blueprint(:with_option_questions) do
  channel       {Channel.make}
  title         {Sham.title}
  description   {Sham.description}
  form_url      {Sham.url}
  post_url      {Sham.url}
  owner         {User.make}
  respondents   {Respondent.make_many(5)}
  questions     {[
    Question.make(:options, :options => %w(foo bar baz), :field_name => 'entry.1.single', :position => 1),
    Question.make(:options, :options => %w(oof rab zab), :field_name => 'entry.2.single', :position => 2)]}
end

Poll.blueprint(:with_numeric_questions) do
  channel       {Channel.make}
  title         {Sham.title}
  description   {Sham.description}
  form_url      {Sham.url}
  post_url      {Sham.url}
  owner         {User.make}
  respondents   {Respondent.make_many(5)}
  questions     {[
    Question.make(:numeric, :numeric_min => 1, :numeric_max => 10, :field_name => 'entry.0.group', :position => 1),
    Question.make(:numeric, :numeric_min => 30, :numeric_max => 40, :field_name => 'entry.1.group', :position => 2)]}
end

Question.blueprint do
  title               {Sham.title}
  description         {Sham.description}
  field_name          {"entry.0"}
  position            {1}
  kind                {:text}
  collects_respondent {false}
end

Question.blueprint(:text) do

end

Question.blueprint(:options) do
  title         {Sham.title}
  description   {Sham.description}
  kind          {:options}
  field_name    {"entry.0"}
  position      {1}
  options       {(0..rand(3)+1).map{Sham.name}}
end

Question.blueprint(:numeric) do
  title         {Sham.title}
  description   {Sham.description}
  field_name    {"entry.0"}
  position      {1}
  kind          {:numeric}
  numeric_min   {rand(3)+1}
  numeric_max   {rand(3)+5}
end

Respondent.blueprint do
  phone {Sham.phone}
end

Answer.blueprint do
  question      {Question.make!}
  respondent    { object.respondent || Respondent.make! }
  response      {Sham.response}
end

class ActiveRecord::Base
  def self.make_many(count, *args)
    (0...count).map {self.make(*args)}
  end
end

class Poll
  def self.plan(*args)
    poll = self.make(*args)
    plan = poll.serializable_hash
    plan.delete :channel
    plan.delete :questions
    plan["questions_attributes"] = {}
    (poll.questions || []).each_with_index do |question,index|
      plan["questions_attributes"][index.to_s] = Question.make(question.attributes).serializable_hash
    end
    plan
  end
end
