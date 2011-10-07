class ApplicationController < ActionController::Base
  protect_from_forgery

  layout proc {|controller| controller.request.xhr? ? false: "application" }
  
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  
  rescue_from ActionController::RedirectBackError do
    redirect_to root_url
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  include BreadcrumbsOnRails::ControllerMixin

  private

  def load_poll(poll_id=nil, attributes=nil)
    @poll = Poll.find (poll_id || params[:poll_id])
    authorize! :manage, @poll
    add_breadcrumb @poll.title, poll_path(@poll)
    @poll.attributes = attributes if attributes
    @poll
  end
  
  def record_not_found
    render :file => "public/400.html", :layout => nil
  end

  def after_sign_in_path_for(resource_or_scope)
    (session[:return_to] || polls_path).to_s
  end
end
