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
  
  def phones_list
    can_edit ? phones : []
  end
  
  def fixed_phones_list
    can_edit ? [] : phones
  end
  
  private
  
  def phones
    @poll.respondents.map{|x| {:number => x.unprefixed_phone}}
  end
  
end
