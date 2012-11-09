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

module ChannelsHelper
  def back_to(step, options={})
    options.merge!(:remote => true)
    white_link_to _('Back'), step_path(step), options
  end

  def next_to(step, options={})
    options.merge!(:remote => true)
    grey_link_to _('Next'), step_path(step), options
  end

  def back_to_start
    if params[:wizard]
      white_link_to _('Back'), edit_poll_path(@poll, :wizard => true)
    else
      white_link_to _('Back'), step_path
    end
  end

  def step_path(step=nil)
    if step
      case params[:controller]
      when 'phone_channels'
        new_poll_phone_channel_path(@poll, :step => step, :wizard => params[:wizard])
      when 'twitter_channels'
        new_poll_twitter_channel_path(@poll, :step => step, :wizard => params[:wizard])
      end
    else
      new_poll_channel_path(@poll, :wizard => params[:wizard])
    end
  end
end
