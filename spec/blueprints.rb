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
  form_url        {Sham.url}
  post_url        {Sham.url}
  owner           {User.make}
  welcome_message {"welcome, press yes"}
  goodbye_message {"goodbye!"}
end

Poll.blueprint(:with_questions) do
  title
  description
  confirmation_word {"yes"}
  form_url      {Sham.url}
  post_url      {Sham.url}
  owner         {User.make}
  welcome_message {"welcome, press yes"}
  goodbye_message {"goodbye!"}
  questions     {[
    Question.make(:field_name => 'entry.0.single', :position => 1),
    Question.make(:options, :options => %w(foo bar baz), :field_name => 'entry.1.single', :position => 2),
    Question.make(:options, :options => %w(oof rab zab), :field_name => 'entry.2.group', :position => 3),
    Question.make(:numeric, :numeric_min => 1, :numeric_max => 10, :field_name => 'entry.3.group', :position => 4)]}
  respondents   {[
    Respondent.make(:phone => "1111"),
    Respondent.make(:phone => "2222"),
    Respondent.make(:phone => "3333"),
    Respondent.make(:phone => "4444"),
    Respondent.make(:phone => "5555")
  ]}
end

Poll.blueprint(:with_text_questions) do
  title
  description
  confirmation_word {"yes"}
  form_url      {Sham.url}
  post_url      {Sham.url}
  owner         {User.make}
  welcome_message {"welcome, press yes"}
  goodbye_message {"goodbye!"}
  questions     {[
    Question.make(:field_name => 'entry.0.single', :position => 1),
    Question.make(:field_name => 'entry.1.single', :position => 2),
    Question.make(:field_name => 'entry.2.single', :position => 3)]}
  respondents   {[
    Respondent.make(:phone => "sms://1111"),
    Respondent.make(:phone => "sms://2222"),
    Respondent.make(:phone => "sms://3333"),
    Respondent.make(:phone => "sms://4444"),
    Respondent.make(:phone => "sms://5555")]}
end

Poll.blueprint(:with_option_questions) do
  title
  description
  confirmation_word {"yes"}
  form_url      {Sham.url}
  post_url      {Sham.url}
  owner         {User.make}
  welcome_message {"welcome, press yes"}
  goodbye_message {"goodbye!"}
  questions     {[
    Question.make(:options, :options => %w(foo bar baz), :field_name => 'entry.1.single', :position => 1),
    Question.make(:options, :options => %w(oof rab zab), :field_name => 'entry.2.single', :position => 2)]}
  respondents   {[
    Respondent.make(:phone => "1111"),
    Respondent.make(:phone => "2222"),
    Respondent.make(:phone => "3333"),
    Respondent.make(:phone => "4444"),
    Respondent.make(:phone => "5555")]}
end

Poll.blueprint(:with_numeric_questions) do
  title
  description
  confirmation_word {"yes"}
  form_url      {Sham.url}
  post_url      {Sham.url}
  owner         {User.make}
  welcome_message {"welcome, press yes"}
  goodbye_message {"goodbye!"}
  questions     {[
    Question.make(:numeric, :numeric_min => 1, :numeric_max => 10, :field_name => 'entry.0.group', :position => 1),
    Question.make(:numeric, :numeric_min => 30, :numeric_max => 40, :field_name => 'entry.1.group', :position => 2)]}
  respondents   {[
    Respondent.make(:phone => "1111"),
    Respondent.make(:phone => "2222"),
    Respondent.make(:phone => "3333"),
    Respondent.make(:phone => "4444"),
    Respondent.make(:phone => "5555")]}
end

Question.blueprint do
  title
  description
  kind          {:text}
  poll          {Poll.make}
end

Question.blueprint(:without_poll) do
  title
  description
  kind          {:text}
  poll          {nil}
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
  position      {1}
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
