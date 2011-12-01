module AuthHelper
  def http_login(user,pw)
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user,pw)
  end  

  def nuntium_http_login
    http_login(Nuntium.config['at_post_user'], Nuntium.config['at_post_pass'])
  end
end
