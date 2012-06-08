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

require 'nokogiri'

module SeleniumHelper
  def get(path)
    if path =~ %r(://)
      @driver.get path
    else
      @driver.get "http://pollit-stg.heroku.com#{path}"
    end
  end

  def unique(name)
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    if name =~ /(.*)@(.*)/
      "#{$1}+#{timestamp}@#{$2}"
    else
      "#{name}#{timestamp}"
    end
  end

  def i_should_see(text)
    unless dom_text.include? text
      sleep 2
      unless dom_text.include? text
        ::RSpec::Expectations.fail_with("Expected to see '#{text}' but couldn't find it on the web page")
      end
    end
  end

  def i_should_not_see(text)
    if dom_text.include? text
      sleep 2
      if dom_text.include? text
        ::RSpec::Expectations.fail_with("Expected not to see '#{text}' but it was found on the web page")
      end
    end
  end

  def get_link(string)
    string =~ /href=(?:"|')(.*?)(?:"|')/ && $1 or raise ::RSpec::Expectations.fail_with("Link not found in #{string}")
  end

  def dom_text
    html = @driver.execute_script('return document.body.innerHTML;')
    doc = Nokogiri::HTML html
    doc.xpath('//script').each &:remove
    doc.inner_text
  end
end
