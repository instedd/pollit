class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google
    auth = env['omniauth.auth']
    
    user = User.find_by_email(auth['user_info']['email'])

    if (user.nil?)
      user = User.new
      user.email = auth['user_info']['email']
      user.name = auth['user_info']['name']
      user.google_token = auth['uid']
      user.save
    end
    
    sign_in user
    redirect_to env['omniauth.origin']
  end
end