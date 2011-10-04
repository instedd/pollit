require 'machinist/active_record'
require 'sham'
require 'faker'

Sham.define do
  title        { Faker::Lorem.words.join(' ') }
  question     { "#{Faker::Lorem.words.join(' ')}?" }
  response     { Faker::Lorem.words.join(' ') }
  description  { Faker::Lorem.paragraph }
  email        { Faker::Internet.email }
  url          { "http://#{Faker::Internet.domain_name}" }
  password     { rand(36**8).to_s(36) }
  name         { Faker::Lorem.words.first }
  phone        { "sms://#{rand(10000)}" }
  ticket_code  { rand(9999) }
end

User.blueprint do
  email
  name
  password
  password_confirmation {password}
  confirmed_at {DateTime.now}
  confirmation_sent_at {DateTime.now}
end

Channel.blueprint do
  ticket_code
  name        
end

Poll.blueprint do
  title           {Sham.title}
  description 
  form_url        {Sham.url}
  post_url        {Sham.url}
  owner           {User.make}
  questions       {[Question.make]}
end

Poll.blueprint(:with_questions) do
  channel           {Channel.make}
  title             {Sham.title}
  description       
  form_url          {Sham.url}
  post_url          {Sham.url}
  owner             {User.make}
  respondents       {Respondent.make_many(5)}
  questions     {[
    Question.make(:field_name => 'entry.0.single', :position => 1),
    Question.make(:options, :options => %w(foo bar baz), :field_name => 'entry.1.single', :position => 2),
    Question.make(:options, :options => %w(oof rab zab), :field_name => 'entry.2.group', :position => 3),
    Question.make(:numeric, :numeric_min => 1, :numeric_max => 10, :field_name => 'entry.3.group', :position => 4)]}  
end

Poll.blueprint(:with_text_questions) do
  channel           {Channel.make}
  title             {Sham.title}
  description
  form_url          {Sham.url}
  post_url          {Sham.url}
  owner             {User.make}
  respondents       {Respondent.make_many(5)}
  questions         {[
    Question.make(:field_name => 'entry.0.single', :position => 1),
    Question.make(:field_name => 'entry.1.single', :position => 2),
    Question.make(:field_name => 'entry.2.single', :position => 3)]}
end

Poll.blueprint(:with_option_questions) do
  channel       {Channel.make}
  title         {Sham.title}
  description
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
  description
  form_url      {Sham.url}
  post_url      {Sham.url}
  owner         {User.make}
  respondents   {Respondent.make_many(5)}
  questions     {[
    Question.make(:numeric, :numeric_min => 1, :numeric_max => 10, :field_name => 'entry.0.group', :position => 1),
    Question.make(:numeric, :numeric_min => 30, :numeric_max => 40, :field_name => 'entry.1.group', :position => 2)]}
end

Question.blueprint do
  title         {Sham.title}
  description   {Sham.description}
  field_name    {"entry.0"}
  position      {1}
  kind          {:text}
end

Question.blueprint(:options) do
  title
  description
  kind          {:options}
  field_name    {"entry.0"}
  position      {1}
  options       {(0..rand(3)+1).map{Sham.name}}
end

Question.blueprint(:numeric) do
  title
  description
  field_name    {"entry.0"}
  position      {1}
  kind          {:numeric}
  numeric_min   {rand(3)+1}
  numeric_max   {rand(3)+5}
end

Respondent.blueprint do
  poll
  phone
end

Answer.blueprint do
  question      {Question.make}
  respondent    {Respondent.make}
  response      
end

class ActiveRecord::Base
  def self.make_many(count, *args)
    (0...count).map {self.make(*args)}
  end
end

class Poll
  def self.plan_with_nesting(*args)
    plan = self.plan_without_nesting(*args)
    plan.delete :channel
    questions = plan.delete :questions
    plan["questions_attributes"] = {}
    questions.each_with_index do |question,index|
      plan["questions_attributes"][index.to_s] = Question.plan(question.attributes)
    end
    plan
  end

  class << self
    alias_method_chain :plan, :nesting
  end
end