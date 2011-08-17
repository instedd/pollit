require 'machinist/active_record'
require 'sham'
require 'faker'

Sham.define do
  title        { Faker::Lorem.words.join }
  question     { "#{Faker::Lorem.words.join}?" }
  response     { Faker::Lorem.words.join }
  description  { Faker::Lorem.paragraph }
  email        { Faker::Internet.email }
  url          { "http://#{Faker::Internet.domain_name}" }
  password     { rand(36**8).to_s(36) }
  name         { Faker::Lorem.words.first }
  phone        { "sms://#{rand(10000)}" }
end

User.blueprint do
  email
  name
  password
  password_confirmation {password}
end

Poll.blueprint do
  title
  description
  form_url      {Sham.url}
  post_url      {Sham.url}
  owner         {User.make}
end

Poll.blueprint(:with_questions) do
  title
  description
  form_url      {Sham.url}
  post_url      {Sham.url}
  owner         {User.make}
  questions     {[
    Question.make(:field_name => 'entry.0.single'),
    Question.make(:options, :options => %w(foo bar baz), :field_name => 'entry.1.single'),
    Question.make(:options, :options => %w(oof rab zab), :field_name => 'entry.2.group'),
    Question.make(:numeric, :numeric_min => 1, :numeric_max => 10, :field_name => 'entry.3.group')]}
end

Question.blueprint do
  title
  description
  kind          {:text}
  poll          {Poll.make}
end

Question.blueprint(:options) do
  title
  description
  kind          {:options}
  poll          {Poll.make}
  options       {(0..rand(3)+1).map{Sham.name}}
end

Question.blueprint(:numeric) do
  title
  description
  kind          {:numeric}
  poll          {Poll.make}
  numeric_min   {rand(3)+1}
  numeric_max   {rand(3)+5}
end

Answer.blueprint do
  question      {Question.make}
  respondent    {Respondent.make}
  response      
end

Respondent.blueprint do
  poll          {Poll.make}
  phone
end
