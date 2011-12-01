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
