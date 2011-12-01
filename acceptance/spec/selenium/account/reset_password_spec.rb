require File.expand_path('../../../spec_helper', __FILE__)

acceptance_test do
  #create account
  email = unique('testingstg@gmail.com')
  get "/"
  @driver.find_element(:link, "Create account").click
  @driver.find_element(:id, "user_email").clear
  @driver.find_element(:id, "user_email").send_keys email
  @driver.find_element(:id, "user_password").clear
  @driver.find_element(:id, "user_password").send_keys "123456789"
  @driver.find_element(:id, "user_password_confirmation").clear
  @driver.find_element(:id, "user_password_confirmation").send_keys "123456789"
  @driver.find_element(:xpath, "//div[contains(@class, 'actions')]/button").click
  i_should_see "You have signed up successfully. However, we could not sign you in because your account is unconfirmed. We have just sent an email to #{email} with an activation link."
  mail_body = get_mail
  link = get_link mail_body
  p link
  sleep 10
  get link
  i_should_see"Your account was successfully confirmed. You are now signed in."
  #reset password
  get '/users/sign_out'
  @driver.find_element(:link, "Log in").click
  @driver.find_element(:link, "Reset it").click
  @driver.find_element(:id, "user_email").clear
  @driver.find_element(:id, "user_email").send_keys email
  @driver.find_element(:xpath, "//div[contains(@class, 'actions')]/button").click
  i_should_see "You will receive an email with instructions about how to reset your password in a few minutes."
  mail_body = get_mail
  link = get_link mail_body
  get link
  @driver.find_element(:id, "user_password").clear
  @driver.find_element(:id, "user_password").send_keys "123456789"
  @driver.find_element(:id, "user_password_confirmation").clear
  @driver.find_element(:id, "user_password_confirmation").send_keys "123456789"
  @driver.find_element(:xpath, "//div[contains(@class, 'actions')]/button").click
end
