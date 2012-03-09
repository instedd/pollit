require File.expand_path('../../../spec_helper', __FILE__)

acceptance_test do
  get "/"
  login_as "mmuller+4691@manas.com.ar", "123456789"
  go_to_my_polls
  @driver.find_element(:xpath, "//table[contains(@class, 'GralTable TwoColumn CleanTable ItemsTable')]/tbody/tr[2]").click
  @driver.find_element(:link, "Delete this poll").click
  #After that press ok button
end