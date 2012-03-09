module AccountHelper
  def login_as(login, password)
    @driver.find_element(:xpath, "//ul[contains(@class, 'RightMenu')]/li[2]/a").click
    @driver.find_element(:id, "user_email").clear
    @driver.find_element(:id, "user_email").send_keys login
    @driver.find_element(:id, "user_password").clear
    @driver.find_element(:id, "user_password").send_keys password
    @driver.find_element(:xpath, "//div[contains(@class, 'actions')]/button").click
  end

  def logout
    get "/users/sign_out"
  end
end
