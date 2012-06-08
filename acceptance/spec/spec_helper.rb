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

require "rubygems"
require "rspec/autorun"
require "selenium-webdriver"
Dir[File.expand_path("../helpers/*.rb", __FILE__)].each do |file|
  require file
end

def acceptance_test(options ={},  &block)
  name = caller[0]
  name = /.*(\/|\\)(.*)\.rb/.
  match(name)[2].gsub('_', ' ')
  describe name do
    include AccountHelper
    include PollsHelper
    include SeleniumHelper
    #include RequestsHelper
    include SettingsHelper
    include MailHelper

    unless options.has_key?(:open_browser) && !options[:open_browser]
      before(:each) do
        @driver = Selenium::WebDriver.for :firefox
        @driver.manage.timeouts.implicit_wait = 60
      end

      after(:each) do
        @driver.quit
      end
    end

    it name, &block
  end
end
