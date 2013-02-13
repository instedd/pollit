source 'http://rubygems.org'

gem 'rails', '3.1.11'
gem 'mysql2'
gem 'jquery-rails'
gem 'fancybox-rails'
gem 'haml-rails'
gem 'devise'
gem 'enumerated_attribute'
gem 'nokogiri'
gem 'hpricot'
gem 'rest-client'
gem 'acts_as_list'
gem 'nuntium_api', :require => 'nuntium'
gem 'breadcrumbs_on_rails'
gem 'cancan', "~> 1.6.7"
gem 'kaminari'
gem 'fast_gettext'
gem 'gettext_i18n_rails'
gem 'mechanize'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 3.1.0'
  gem 'coffee-rails', '~> 3.1.0'
  gem 'uglifier'
end

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem 'machinist'
  gem 'mocha'
  gem 'webmock'
  gem 'ci_reporter'
  gem 'cover_me'
  gem 'rcov'
end

group :development do
  gem 'gettext', :git => 'https://github.com/cameel/gettext.git', :ref => 'c3a8373'
  gem 'ruby_parser'
  gem 'locale'
  gem 'wirble'
  gem 'capistrano'
  gem 'rvm'
  gem 'licit'
end

group :test, :development do
  gem 'pry'
  gem 'pry-debugger'
  gem 'rspec-rails'
  gem 'faker'
end
