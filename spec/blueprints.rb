require 'machinist/active_record'
require 'sham'
require 'faker'

Sham.define do
  title        { Faker::Lorem.words.join }
  question     { "#{Faker::Lorem.words.join}?" }
  description  { Faker::Lorem.paragraph }
  email        { Faker::Internet.email }
  url          { "http://#{Faker::Internet.domain_name}" }
  password     { rand(36**8).to_s(36) }
  name         { Faker::Lorem.words.first }
end

Poll.blueprint do
  title
  description
  url
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