require File.expand_path('../../../spec_helper', __FILE__)

acceptance_test do
  get "/"
  login_as "mmuller+4691@manas.com.ar", "123456789"
  go_to_my_polls
  2.upto 6 do |n|
    answers = @driver.find_element(:xpath, "//table[contains(@class, 'GralTable TwoColumn CleanTable ItemsTable')]/tbody/tr[#{n}]//span").text.to_i
    if answers == 0
      break
    end
  end

  fail "No poll with zero answers was found"
  
  @driver.find_element(:xpath, "//table[contains(@class, 'GralTable TwoColumn CleanTable ItemsTable')]/tbody/tr[5]").click
  @driver.find_element(:link, "Manage Channel").click
  @driver.find_element(:link, "Change channel").click
  sleep 5
  @driver.find_element(:id, "desktopLocalGateway").click
  @driver.find_element(:id, "next").click
  sleep 5
  @driver.find_element(:link, "Next").click
  @driver.find_element(:id, "channel_ticket_code").clear
  @driver.find_element(:id, "channel_ticket_code").send_keys "123456"
  @driver.find_element(:xpath, "//button[contains(@class, 'grey')]").click
  i_should_see "invalid code"
end
