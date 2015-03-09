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

class Api::AnswersController < ApiController

  before_filter :load_poll
  before_filter :load_answers, only: :index

  def index
    respond_to do |format|
      format.xml   { render :xml => @answers.map(&:for_api)  }
      format.json  { render :json => @answers.map(&:for_api) }
    end
  end

  def show
    @answer = @poll.answers.find(params[:id])
    respond_to do |format|
      format.xml   { render :xml => @answer.for_api  }
      format.json  { render :json => @answer.for_api }
    end
  end

  private

  def load_poll
    @poll = current_user.polls.find(params[:poll_id])
  end

  def load_answers
    @answers = @poll.answers.joins(:respondent).includes(:question)
    @answers = @answers.where('respondents.phone' => params[:respondent_phone].ensure_protocol) unless params[:respondent_phone].blank?

    %w(occurrence question_id respondent_id).each do |field|
      @answers = @answers.where(field => params[field]) unless params[field].blank?
    end
  end

end
