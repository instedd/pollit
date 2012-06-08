# Copyright (C) 2011-2012, InSTEDD
# 
# This file is part of Pollit.
# 
# Pollit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# Pollit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Pollit.  If not, see <http://www.gnu.org/licenses/>.

class ApplicationController < ActionController::Base
  include BreadcrumbsOnRails::ControllerMixin

  protect_from_forgery

  before_filter :set_gettext_locale
  before_filter :redirect_to_localized_url
  before_filter :set_steps

  layout :set_layout

  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  rescue_from ActionController::RedirectBackError do
    redirect_to root_url
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  protected

  def redirect_to_localized_url
    redirect_to params if params[:locale].nil? && request.get?
  end

  def default_url_options(options={})
    {:locale => I18n.locale.to_s}
  end

  def set_layout
    request.xhr? ? false : "application"
  end

  def wizard?
    params[:wizard]
  end

  def set_steps
    @steps = [_('Properties'),_('Channel'),_('Respondents'),_('Finish')]
    @wizard_step ||= _('Properties')
  end

  private

  def load_poll(poll_id=nil, attributes=nil)
    @poll = Poll.find (poll_id || params[:poll_id])
    authorize! :manage, @poll
    unless params[:wizard]
      add_breadcrumb _("Polls"), :polls_path
      add_breadcrumb @poll.title, poll_path(@poll)
    end
    @poll.attributes = attributes if attributes
    @poll
  end

  def record_not_found
    render :file => "public/400.html", :layout => nil
  end

  def after_sign_in_path_for(resource_or_scope)
    user = resource_or_scope
    if user.lang
      I18n.locale = user.lang.to_sym
    elsif I18n.locale
      user.lang = I18n.locale.to_s
      user.save
    end
    (session[:return_to] || polls_path).to_s
  end

  def after_sign_out_path_for(resource_or_scope)
    home_path
  end
end
