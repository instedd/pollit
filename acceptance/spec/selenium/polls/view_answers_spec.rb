require File.expand_path('../../../spec_helper', __FILE__)

acceptance_test do
  get "/"
  login_as "mmuller+4691@manas.com.ar", "123456789"
  go_to_my_polls
  2.upto 6 do |n|
    answers = @driver.find_element(:xpath, "//table[contains(@class, 'GralTable TwoColumn CleanTable ItemsTable')]/tbody/tr[#{n}]//span").text.to_i
    if answers != 0
        sleep 5
        @driver.find_element(:xpath, "//table[contains(@class, 'GralTable TwoColumn CleanTable ItemsTable')]/tbody/tr[#{n}]").click
        @driver.find_element(:link, "Answers").click
        i_should_see "Respondent"
      break
    end
  end
  
end
