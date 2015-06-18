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

  before_filter :except => [:index, :new, :new_gforms, :new_manual, :create, :import_form] do
    load_poll(params[:id])
  end

  before_filter :only => [:index, :new, :new_gforms, :new_manual, :create, :import_form] do
    add_breadcrumb _("Polls"), :polls_path
  end

  before_filter :only => [:new_gforms, :new_manual] do
    @wizard_step = _('Properties')
    @wizard = params[:wizard] = true
  end

  def index
    @polls = current_user.polls
  end

  def show
  end

  def new
    params[:wizard] = true
    @wizard_step = _('Type')
  end

  def new_gforms
    @poll = Poll.new kind: 'gforms'
    render :new_properties
  end

  def new_manual
    @poll = Poll.new kind: 'manual'
    render :new_properties
  end

  def create
    @poll = current_user.polls.build params[:poll]

    if @poll.save
      redirect_to new_poll_channel_path(@poll, :wizard => true)
    else
      render 'new_properties'
    end
  end

  def edit
  end

  def update
    # Mark for destruction all missing questions
    qs_attrs = params[:poll][:questions_attributes]
    @poll.questions.each do |q|
      q.mark_for_destruction unless qs_attrs.any?{|attrs| attrs['id'] == q.id.to_s}
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
      previous_respondent_question = params[:poll][:questions_attributes].find{|data| data[:collects_respondent] == 'true'} rescue nil
      attrs = params[:poll].merge(:questions_attributes => {})
      imported = Poll.new attrs
      imported.owner_id = current_user.id
      imported.questions = []
      imported.parse_form
      imported.generate_unique_title! if params[:poll][:title].blank?

      respondent_question = imported.questions.find{|q| q.title.strip == previous_respondent_question[:title].strip} if previous_respondent_question
      respondent_question.collects_respondent = true if respondent_question

      @poll = unless params[:id].blank? then load_poll(params[:id], attrs) else imported end
      @data = @poll.as_json
      @data['questions'] = imported.questions.as_json
    rescue Exception => error
      logger.error "Error importing form: #{error.inspect}\n#{error.backtrace.join("\n")}"
      @error = error
    ensure
      if @error
        render json: {error: @error}, status: :unprocessable_entity
      else
        render json: @data
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

  def run_next_job
    @poll.next_job.invoke_job
    redirect_to :back
  end

  protected

  def set_layout
    if !request.xhr? && [:new, :new_gforms, :new_manual, :create, :edit, :update].include?(params[:action].to_sym)
      'wizard'
    else
      super
    end
  end

end
