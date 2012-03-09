require File.expand_path('../../../spec_helper', __FILE__)

acceptance_test do
  get "/polls/8"
  @driver.find_element(:id, "user_email").clear
  @driver.find_element(:id, "user_email").send_keys "mmu+3@manas.com.ar"
  @driver.find_element(:id, "user_password").clear
  @driver.find_element(:id, "user_password").send_keys "123456789"
  @driver.find_element(:xpath, "//div[contains(@class, 'actions')]/button").click
  i_should_see "Invalid email or password."

end