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

require File.expand_path('../../../spec_helper', __FILE__)

acceptance_test do
  get "/"
  login_as "mmuller+4691@manas.com.ar", "123456789"
  go_to_my_polls
  @driver.find_element(:xpath, "//table[contains(@class, 'GralTable TwoColumn CleanTable ItemsTable')]/tbody/tr[10]").click
  @driver.find_element(:link, "Manage Respondents").click
  sleep 5
  @driver.find_element(:id, "numberText").clear
  @driver.find_element(:id, "numberText").send_keys "999124578"
  @driver.find_element(:xpath, "//button[contains(@class, 'clist-add ng-directive')]").click
  @driver.find_element(:id, "numberText").send_keys "999235689"
  @driver.find_element(:xpath, "//button[contains(@class, 'clist-add ng-directive')]").click
  @driver.find_element(:xpath, "//button[contains(@class, 'grey  ng-directive')]").click
  i_should_see "Phones saved succesfully!"
end
