# coding: utf-8

require File.expand_path('../../../spec_helper', __FILE__)

acceptance_test do  
  get "/"
  #Spanish
  @driver.find_element(:link, "Español").click
  #i_should_see 'Crear cuenta'
  #English
  @driver.find_element(:link, "English").click
  i_should_see 'Create account'

end
