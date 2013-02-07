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

class PollsController < ApplicationController


  before_filter :authenticate_user!
  before_filter :set_steps

  before_filter :except => [:index, :new, :create, :import_form] do
    load_poll(params[:id])
  end
  before_filter :only => [:index, :new, :create, :import_form] do
    add_breadcrumb _("Polls"), :polls_path
  end

  def index
    @polls = current_user.polls
  end

  def show
  end

  def new
    @poll = Poll.new
    params[:wizard] = true
  end

  def create
    @poll = current_user.polls.build params[:poll]

    if @poll.save
      redirect_to new_poll_channel_path(@poll, :wizard => true)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    # Mark for destruction all missing questions
    qs_attrs = params[:poll][:questions_attributes]
    @poll.questions.each do |q|
      q.mark_for_destruction unless qs_attrs.any?{|k,v| v['id'] == q.id.to_s}
    end

    # Update
    if @poll.update_attributes(params[:poll])
      if params[:wizard]
        redirect_to poll_channel_path(@poll, :wizard => true)
      else
        redirect_to @poll, :notice => "Poll #{@poll.title} has been updated"
      end
    else
      render :action => 'edit'
    end
  end

  def import_form
    begin
      attrs = params[:poll].merge(:questions_attributes => {})
      imported = Poll.new attrs
      imported.owner_id = current_user.id
      imported.questions = []
      imported.parse_form
      imported.generate_unique_title! if params[:poll][:title].blank?

      @poll = unless params[:id].blank? then load_poll(params[:id], attrs) else imported end
      @questions = imported.questions
    rescue Exception => error
      @error = error
    ensure
      if request.xhr?
        render 'import_form', :layout => false
      else
        render :partial => 'form'
      end
    end
  end

  def destroy
    @poll.destroy
    redirect_to polls_path, :notice => _("Poll %{title} has been deleted") % {:title => @poll.title}
  end

  def register_channel
    @poll.register_channel(params[:ticket_code])
  end

  def start
    if @poll.start
      redirect_to :back, :notice => _("Poll %{title} has been started") % {:title => @poll.title}
    else
      redirect_to :back, :alert => _("Poll %{title} has failed to start") % {:title => @poll.title}
    end
  end

  def pause
    if @poll.pause
      redirect_to :back, :notice => _("Poll %{title} has been paused") % {:title => @poll.title}
    else
      redirect_to :back, :alert => _("Poll %{title} has failed to pause") % {:title => @poll.title}
    end
  end

  def resume
    if @poll.resume
      redirect_to :back, :notice => _("Poll %{title} has been resumed") % {:title => @poll.title}
    else
      redirect_to :back, :alert => _("Poll %{title} has failed to resume") % {:title => @poll.title}
    end
  end

  protected

  def set_layout
    if !request.xhr? && [:new, :create, :edit, :update].include?(params[:action].to_sym)
      'wizard'
    else
      super
    end
  end

end
