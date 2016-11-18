source 'http://rubygems.org'

gem 'rails', '3.2.21'
gem 'mysql2', '~> 0.3.17'
gem 'jquery-rails'
gem 'fancybox-rails'
gem 'haml-rails'
gem 'sass'
gem 'devise', '1.5.4'
gem 'enumerated_attribute', :git => "https://github.com/jeffp/enumerated_attribute.git"
gem 'nokogiri'
gem 'hpricot'
gem 'rest-client'
gem 'acts_as_list'
gem 'nuntium_api', :require => 'nuntium'
gem 'breadcrumbs_on_rails', "~> 2.3"
gem 'cancan', "~> 1.6.7"
gem 'kaminari'
gem 'fast_gettext'
gem 'gettext_i18n_rails'
gem 'mechanize'
gem 'ice_cube'
gem 'recurring_select', git: "https://github.com/instedd/recurring_select", branch: 'instedd'
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'foreman', '0.64.0'
gem 'knockoutjs-rails'
gem 'knockout_forms-rails', git: "https://github.com/manastech/knockout_forms-rails.git", tag: 'v1.0.2'
gem 'gon'
gem 'activerecord-import', '~> 0.3.1'
gem "guid"
gem 'rgviz'
gem 'rgviz-rails', :require => 'rgviz_rails'
gem 'instedd_telemetry', git: 'https://github.com/instedd/telemetry_rails.git'

gem "omniauth"
gem "omniauth-openid"
gem 'ruby-openid'
gem 'rack-oauth2'
gem 'alto_guisso', git: "https://github.com/instedd/alto_guisso.git", branch: 'master'
gem 'alto_guisso_rails', git: "https://github.com/instedd/alto_guisso_rails.git", branch: 'master'
gem 'hub_client', github: 'instedd/ruby-hub_client', branch: 'master'
gem 'listings'
gem 'io-console'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 3.2.0'
  gem 'coffee-rails', '~> 3.2.0'
  gem 'uglifier'
end

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem 'machinist'
  gem 'mocha'
  gem 'webmock'
end

group :development do
  gem 'gettext', :git => 'https://github.com/cameel/gettext.git', :ref => 'c3a8373'
  gem 'ruby_parser'
  gem 'locale'
  gem 'wirble'
  gem 'capistrano', '2.15.5'
  gem 'rvm'
  gem 'licit'
end

group :test, :development do
  gem 'pry-byebug'
  gem 'rspec-rails'
  gem 'faker'
end

group :webserver do
  gem 'puma', '~> 3.0.2'
end
