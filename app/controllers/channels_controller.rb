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

class ChannelsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :load_poll

  def show
    redirect_to :action => 'new', :wizard => params[:wizard] and return unless @poll.channel
    @channel = @poll.channel
    render :layout => 'wizard' if params[:wizard]
  end

  def new
    set_current_step(params[:step] || "a_choose_local_gateway")
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @poll.channel.destroy if @poll.channel
    @channel = @poll.register_channel(params[:channel][:ticket_code])

    if @channel.valid?
      if params[:wizard]
        redirect_to poll_respondents_path(@poll, :wizard => true)
      elsif request.xhr?
        set_current_step("d_end_wizard")
        render 'new'
      else
        redirect_to new_poll_channel_path(@poll, "d_end_wizard")
      end
    else
      set_current_step(params[:next_step])
      render "new"
    end
  end

  def destroy
    @poll.channel.destroy if @poll.channel
    flash[:notice] = _('Channel successfully deleted')
    redirect_to poll_path(@poll)
  end

  protected

  def set_steps
    if params[:action].to_sym == :show
      @wizard_step = _("Channel")
      return super
    end

    @steps = [_("Choose"), _("Install"), _("Connect"), _("Finish")]
    @dotted_steps = [_("Properties"), _("Choose"), _("Install"), _("Connect"), _("Respondents")]
    @wizard_step = _('Choose')
  end

  private

  def set_current_step(step)
    @step = step
    {"a" => _("Choose"), "b" => _("Install"), "c" => _("Connect"), "d" => _("Finish")}.each_pair do |k,v|
      @wizard_step = v if @step.start_with?(k)
    end
  end
end
