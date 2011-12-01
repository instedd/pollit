sleep 5
        @driver.find_element(:id, "desktopLocalGateway").click
        @driver.find_element(:id, "next").click
        sleep 5
        @driver.find_element(:link, "Next").click
        @driver.find_element(:id, "channel_ticket_code").clear
        @driver.find_element(:id, "channel_ticket_code").send_keys "123456"
        @driver.find_element(:xpath, "//button[contains(@class, 'grey')]").click