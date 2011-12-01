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
