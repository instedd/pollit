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

class Api::RespondentsController < ApiController

  before_filter :load_poll

  def index
    @respondents = @poll.respondents
    respond_to do |format|
      format.xml   { render :xml => @respondents  }
      format.json  { render :json => @respondents }
    end
  end

  def show
    @respondent = @poll.respondents.find(params[:id])
    respond_to do |format|
      format.xml   { render :xml => @respondent  }
      format.json  { render :json => @respondent }
    end
  end

  private

  def load_poll
    @poll = current_user.polls.find(params[:poll_id])
  end

end
