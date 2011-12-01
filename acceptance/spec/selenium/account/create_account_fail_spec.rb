require File.expand_path('../../../spec_helper', __FILE__)

acceptance_test do
  get "/"
  @driver.find_element(:link, "Create account").click
  @driver.find_element(:id, "user_email").clear
  @driver.find_element(:id, "user_email").send_keys "mmuller+4691@manas.com.ar"
  @driver.find_element(:id, "user_password").clear
  @driver.find_element(:id, "user_password").send_keys "123456789"
  @driver.find_element(:id, "user_password_confirmation").clear
  @driver.find_element(:id, "user_password_confirmation").send_keys "123456789"
  @driver.find_element(:xpath, "//div[contains(@class, 'actions')]/button").click
  i_should_see "Email has already been taken"  
end
