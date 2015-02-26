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

class Api::QuestionsController < ApiController

  before_filter :load_poll

  def index
    @questions = @poll.questions.order(:position)
    respond_to do |format|
      format.xml   { render :xml => @questions  }
      format.json  { render :json => @questions }
    end
  end

  def show
    @question = @poll.questions.find(params[:id])
    respond_to do |format|
      format.xml   { render :xml => @question  }
      format.json  { render :json => @question }
    end
  end

  private

  def load_poll
    @poll = current_user.polls.find(params[:poll_id])
  end

end
