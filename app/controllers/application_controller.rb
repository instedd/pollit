class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  private
  
  def record_not_found
    render :file => "public/400.html", :layout => nil
  end

  def after_sign_in_path_for(resource_or_scope)
    (session[:return_to] || polls_path).to_s
  end
end
