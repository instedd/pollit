class ApplicationController < ActionController::Base
  protect_from_forgery

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exceptions::InvalidAction do
      render :file => "public/400.html", :status => :badrequest, :layout => nil
    end
  end

  private
  
  def after_sign_in_path_for(resource_or_scope)
    (session[:return_to] || polls_path).to_s
  end

end
