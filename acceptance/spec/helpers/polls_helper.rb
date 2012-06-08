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

module PollsHelper
  def go_to_my_polls
    @driver.find_element(:link, "Polls").click
  end

  def create_poll(options = {})
    title = unique('Poll')
    go_to_my_polls
    @driver.find_element(:xpath, "//button[contains(@class, 'cadd')]").click
    @driver.find_element(:id, "poll_form_url").clear
    @driver.find_element(:id, "poll_form_url").send_keys "https://docs.google.com/a/manas.com.ar/spreadsheet/viewform?hl=en_US&pli=1&formkey=dG1RSS1fMHpmSkFiVjNrZnZvcENyTlE6MQ#gid=0"    
    @driver.find_element(:xpath, "//div[contains(@class, 'field')]/button").click
    sleep 15
    @driver.find_element(:id, "poll_title").clear
    @driver.find_element(:id, "poll_title").send_keys options[:title]
    @driver.find_element(:id, "poll_description").clear
    @driver.find_element(:id, "poll_description").send_keys options[:description]
    @driver.find_element(:xpath, "//div[contains(@class, 'actions')]/button").click
  end
 
end
