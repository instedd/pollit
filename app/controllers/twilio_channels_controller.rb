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

class TwilioChannelsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_poll, only: :new

  def new
    set_current_step(params[:step] || 'a_twilio_login')

    if @step.start_with?('b')
      puts ::Pollit::TwilioAccountSid
      puts session[:twilio_account_sid]
      client = Twilio::REST::Client.new ::Pollit::TwilioAccountSid, ::Pollit::TwilioAuthToken
      @numbers = client.account.incoming_phone_numbers.list
      p @numbers
    end
  end

  def callback
    account_sid = params[:AccountSid]
    poll_id = params[:state]

    session[:twilio_account_sid] = account_sid

    redirect_to new_poll_twilio_channel_path(poll_id, step: 'b_select_number')
  end

  private

  def set_steps
    if params[:action].to_sym == :show
      @wizard_step = _("Channel")
      return super
    end

    @steps = [_("Twilio login"), _("Select number"), _("Finish")]
    @dotted_steps = [_("Properties"), _("Select number"), _("Respondents")]
    @wizard_step = _('Select number')
  end

  def set_current_step(step)
    @step = step
    {"a" => _("Twilio login"), "b" => _("Select number"), "c" => _("Finish")}.each_pair do |k,v|
      @wizard_step = v if @step.start_with?(k)
    end
  end
end
