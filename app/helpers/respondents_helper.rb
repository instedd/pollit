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

module RespondentsHelper
  def can_edit
    @poll.status_configuring?
  end

  def respondents_list
    can_edit ? respondents_list : []
  end

  def fixed_respondents_list
    can_edit ? [] : respondents_list
  end

  private

  def respondents_list
    @poll.respondents.map { |x| {:phone => x.unprefixed_phone, :twitter => x.unprefixed_twitter} }
  end
end
