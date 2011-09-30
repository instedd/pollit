class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  include BreadcrumbsOnRails::ControllerMixin

  def self.before_filter_load_poll(opts = {})
    raise "Foo"
    before_filter opts do
      @poll = Poll.find params[:poll_id]
      
      authorize! 
      add_breadcrumb "Polls", :polls_path
      add_breadcrumb @poll.title, poll_path(@poll)
    end
  end

  private

  def load_poll(poll_id=nil)
    @poll = Poll.find (poll_id || params[:poll_id])
    authorize! :manage, @poll
    add_breadcrumb @poll.title, poll_path(@poll)
  end
  
  def record_not_found
    render :file => "public/400.html", :layout => nil
  end

  def after_sign_in_path_for(resource_or_scope)
    (session[:return_to] || polls_path).to_s
  end
end
